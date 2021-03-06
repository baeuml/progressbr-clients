function [ uuid, json ] = pbr_create( varargin )
%PBR_CREATE creates a new progress bar.
%   UUID = PBR_CREATE(N) creates a new progress bar with N update steps.
%   
%   UUID = PBR_CREATE(FIRST, LAST) creates a new progress bar for updates
%   from FIRST to LAST.
%   
%   UUID = PBR_CREATE(..., 'Description', DESCR) creates a new progress bar 
%   with description DESCR.


import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% parse parameters
params = parse_args(varargin{:});
    
url = [params.base_url, '/api/progress'];
if strcmp(url(1:5), 'https')
    handler = sun.net.www.protocol.https.Handler;
else
    handler = sun.net.www.protocol.http.Handler;
end
url = java.net.URL([], url, handler);
conn = url.openConnection();

% header
conn.setRequestProperty('User-Agent', 'matlab client');
conn.setRequestProperty('Content-Type','application/json');
private_key = getenv('PBR_PRIVATE_KEY');
if ~isempty(private_key)
    conn.setRequestProperty('Authorization', ['PBR ' private_key]);
end

% build request data
data = '{\n';
data = [data '  "range_min": ' num2str(round(params.range_min)) ',\n'];
data = [data '  "range_max": ' num2str(round(params.range_max)) ''];
if ~isempty(params.description)
    data = [data ',\n  "description": "' params.description '"'];
end
data = [data '\n}'];
data = sprintf(data);

% init uuid return value, set to empty for error case
uuid = [];

% POST the data
try
    conn.setDoOutput(true);
    stream = java.io.PrintStream(conn.getOutputStream());
    stream.print(data);
    stream.close();
catch
    warning('Error during connecting');
    return;
end

% read response
try
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
catch
    warning('Error during request');
    return;
end

end


function params = parse_args(varargin)

params.range_min = 1;
params.range_max = [];
params.description = '';
params.base_url = 'https://progressbr.herokuapp.com';

if isempty(varargin)
    error('not enough parameter');
end

if ~isnumeric(varargin{1})
    error('expected numerical parameter')
end

if length(varargin) >= 2 && isnumeric(varargin{2})
    params.range_min = varargin{1};
    params.range_max = varargin{2};
    next = 3;
else
    params.range_max = varargin{1};
    next = 2;
end

for k = next:2:length(varargin)
    if ~ischar(varargin{k})
        error('expected parameter key at position %d', k);
    end
    
    switch lower(varargin{k})
        case {'desc', 'descr', 'description'}
            params.description = varargin{k+1};
            
        case {'base', 'base_url'}
            params.base_url = varargin{k+1};
            
        otherwise
            error('unknown parameter');
    end
end

end

