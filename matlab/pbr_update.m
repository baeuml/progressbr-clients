function [ succeed ] = pbr_update( varargin )
%PBR_UPDATE updates progress on an existing progress bar.
%   PBR_UPDATE(UUID, N) updates progress on progress bar UUID up to item N.
%   
%   PBR_UPDATE(UUID, FIRST, LAST) updates progress on items FIRST to LAST.
%   
%   PBR_UPDATE(..., 'Description', DESCR) sets the update's description 
%   to DESCR.


import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% parse parameters
params = parse_args(varargin{:});
    
url = [params.base_url, '/api/progressupdate'];
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

% build request data
data = '{\n';
data = [data '  "progress_id": "' params.uuid '",\n'];
data = [data '  "n_min": ' num2str(round(params.n_min)) ',\n'];
data = [data '  "n_max": ' num2str(round(params.n_max)) ''];
if ~isempty(params.description)
    data = [data ',\n  "description": "' params.description '"'];
end
data = [data '\n}'];
data = sprintf(data);

% init return value, set to false for error case
succeed = false;

% POST the data
try
    conn.setDoOutput(true);
    stream = java.io.PrintStream(conn.getOutputStream());
    stream.print(data);
    stream.close();
catch e
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

    succeed = true;
    return;
catch e
    warning('Error during request');
    return;
end

end


function params = parse_args(varargin)

params.n_min = 1;
params.n_max = [];
params.description = '';
params.base_url = 'https://progressbr.herokuapp.com';

if isempty(varargin)
    error('not enough parameter');
end

if ~ischar(varargin{1})
    error('expected uuid parameter')
end

params.uuid = varargin{1};

if length(varargin) >= 3 && isnumeric(varargin{3})
    params.n_min = varargin{2};
    params.n_max = varargin{3};
    next = 4;
else
    params.n_max = varargin{2};
    next = 3;
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

