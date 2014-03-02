function [ uuid, json ] = pbr_create( range1, range2, description, base_url )
%PBR_CREATE creates a new progress bar.
%   UUID = PBR_CREATE(N) creates a new progress bar with N update steps.
%   
%   UUID = PBR_CREATE(FIRST, LAST) creates a new progress bar for updates
%   from FIRST to LAST.

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

if ~exist('base_url', 'var')
    base_url = 'https://progressbr.herokuapp.com/api/';
end
url = [base_url, 'progress'];

if strcmp(base_url(1:5), 'https')
    handler = sun.net.www.protocol.https.Handler;
else
    handler = sun.net.www.protocol.http.Handler;
end
url = java.net.URL([], url, handler);
conn = url.openConnection();

% header
conn.setRequestProperty('User-Agent', 'matlab client');
conn.setRequestProperty('Content-Type','application/json');
% TODO set Authorization header

% build request data
data = '{\n';
% TODO handle range & description
data = [data '  "range_max": ' num2str(round(range1)) '\n'];
data = [data '}'];
data = sprintf(data);

% POST the data
conn.setDoOutput(true);
stream = java.io.PrintStream(conn.getOutputStream());
stream.print(data);
stream.close();

% read response
ostream = java.io.ByteArrayOutputStream();
istream = conn.getInputStream();
isc = InterruptibleStreamCopier.getInterruptibleStreamCopier();
isc.copyStream(istream, ostream);
istream.close();
ostream.close();

% decode response
json = native2unicode(typecast(ostream.toByteArray', 'uint8'), 'utf-8');

% get uuid from json
uuid = regexp(json, '"uuid": "([a-z0-9-])*', 'tokens', 'once');
uuid = uuid{1};

end

