function tleCategoryTrackerGUI
% Create figure
fig = uifigure('Name', 'Satellite Tracker', 'Position', [100 100 600 400]);

% TLE input (multiline text area)
tleLabel = uilabel(fig, 'Position', [20 350 100 22], 'Text', 'Enter TLE (3 lines):');
tleArea = uitextarea(fig, 'Position', [20 220 300 120]);

% Default example TLE (ISS)
defaultTLE = ["ISS (ZARYA)"; ...
    "1 25544U 98067A   25264.54798380  .00000291  00000-0  13852-4 0  9990"; ...
    "2 25544  51.6416 331.1869 0007389 276.6606  80.1682 15.50276128365006"];
tleArea.Value = defaultTLE;

% Start and Stop buttons
startBtn = uibutton(fig, 'push', 'Text', 'Start Tracking', ...
    'Position', [350 320 100 30], 'ButtonPushedFcn', @startTracking);
stopBtn = uibutton(fig, 'push', 'Text', 'Stop Tracking', ...
    'Position', [350 280 100 30], 'ButtonPushedFcn', @stopTracking, ...
    'Enable', 'off');

% Telemetry display labels
latLabel = uilabel(fig, 'Position', [350 230 200 22], 'Text', 'Latitude: ');
lonLabel = uilabel(fig, 'Position', [350 200 200 22], 'Text', 'Longitude: ');
altLabel = uilabel(fig, 'Position', [350 170 200 22], 'Text', 'Altitude (km): ');
speedLabel = uilabel(fig,'Position', [350 140 200 22], 'Text', 'Speed (km/s): ');
utcLabel = uilabel(fig, 'Position', [350 110 200 22], 'Text', 'UTC Time: ');

fig.UserData.stopRequested = false;

    function startTracking(~, ~)
        startBtn.Enable = 'off';
        stopBtn.Enable = 'on';
        fig.UserData.stopRequested = false;

        tleLines = tleArea.Value;
        if numel(tleLines) ~= 3
            uialert(fig, 'Please enter exactly 3 lines of TLE data.', 'Invalid Input');
            startBtn.Enable = 'on';
            stopBtn.Enable = 'off';
            return
        end

        tempTLEFile = fullfile(pwd, 'tempSatTLE.tle');
        fid = fopen(tempTLEFile, 'w');
        fprintf(fid, '%s\n%s\n%s\n', tleLines{1}, tleLines{2}, tleLines{3});
        fclose(fid);

        runRealtimeViewer(tempTLEFile);
    end

    function stopTracking(~, ~)
        fig.UserData.stopRequested = true;
    end

    function runRealtimeViewer(tleFile)
        startTime = datetime('now','TimeZone','UTC');
        stopTime = startTime + minutes(17);
        sampleTime = 1;

        scenario = satelliteScenario(startTime, stopTime, sampleTime);
        scenario.AutoSimulate = false;

        sat = satellite(scenario, tleFile);
        groundStation(scenario, 28.7041, 77.1025, 'Name', 'Delhi GS');
        conicalSensor(sat, 'MaxViewAngle', 45, 'Name', 'Sensor');

        viewer = satelliteScenarioViewer(scenario);
        viewer.ShowDetails = true;

        logFileName = fullfile(pwd, 'telemetry_log.csv');
        fid = fopen(logFileName,'w');
        fprintf(fid,"UTC,Latitude,Longitude,Altitude_km,Speed_kmps\n");

        geoFig = figure('Name','2D Ground Track');
        gx = geoaxes(geoFig);
        geobasemap(gx, "satellite");
        hold(gx, 'on');
        track = geoplot(gx, NaN, NaN, 'r.-', 'DisplayName', 'Ground Track');
        nadirMarker = geoplot(gx, NaN, NaN, 'bo', 'MarkerSize', 8, 'LineWidth', 2, ...
            'DisplayName', 'Current Nadir');
        legend(gx, 'show', 'Location', 'southoutside');

        latList = [];
        lonList = [];
        numSteps = seconds(stopTime - startTime) / sampleTime;

        for i = 1:numSteps
            if fig.UserData.stopRequested || ~isvalid(fig)
                break;
            end

            advance(scenario);
            utcTime = datetime('now','TimeZone','UTC'); % Use real-time UTC
            [pos, vel] = states(sat, utcTime, 'CoordinateFrame', 'ecef');

            % Convert ECEF to Lat, Lon, Alt using recommended function
            lla = ecef2lla(pos');  % Returns [lat lon alt] in meters
            lat = lla(1);
            lon = mod(lla(2) + 180, 360) - 180;  % Wrap longitude
            alt = lla(3) / 1000;  % Convert altitude to km

            speed = norm(vel) / 1000;  % Speed in km/s

            fprintf(fid, "%s,%.6f,%.6f,%.3f,%.4f\n", ...
                datestr(utcTime, 'yyyy-mm-dd HH:MM:ss'), lat, lon, alt, speed);

            if isvalid(latLabel)
                latLabel.Text = sprintf("Latitude: %.6f°", lat);
                lonLabel.Text = sprintf("Longitude: %.6f°", lon);
                altLabel.Text = sprintf("Altitude (km): %.3f", alt);
                speedLabel.Text = sprintf("Speed (km/s): %.4f", speed);
                utcLabel.Text = sprintf("UTC Time: %s", datestr(utcTime, 'yyyy-mm-dd HH:MM:ss'));
            end

            if isvalid(track)
                latList(end+1) = lat;
                lonList(end+1) = lon;
                set(track, 'LatitudeData', latList, 'LongitudeData', lonList);
                set(nadirMarker, 'LatitudeData', lat, 'LongitudeData', lon);
                drawnow limitrate;
            end

            pause(sampleTime);
        end

        fclose(fid);
        disp(['Telemetry logged to: ', logFileName]);
        if isvalid(startBtn)
            startBtn.Enable = 'on';
            stopBtn.Enable = 'off';
        end
    end
end