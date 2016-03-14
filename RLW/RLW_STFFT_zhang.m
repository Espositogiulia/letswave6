function [out_header,out_data,message_string,time_header]=RLW_STFFT_zhang(header,data,varargin);
%RLW_STFFT_zhang
%
%ST-FFT (Zhang)
%
%varargin
%'hanning_width' (0.25)
%'low_frequency' (1)
%'high_frequency' (30
%'num_frequency_lines' (100)
%'postprocess' ('amplitude') 'amplitude','power','phase','complex'
%'average_epochs' (1)
%'segment_data' (0)
%'event_name' []
%'x_start' (-0.5)
%'x_end' (1)
%
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information
%

hanning_width=0.25;
low_frequency=1;
high_frequency=30;
num_frequency_lines=100;
postprocess='amplitude';
average_epochs=1;
segment_data=0;
event_name=[];
x_start=-0.5;
x_end=1;


%parse varagin
if isempty(varargin);
else
    %hanning_width
    a=find(strcmpi(varargin,'hanning_width'));
    if isempty(a);
    else
        hanning_width=varargin{a+1};
    end;
    %low_frequency
    a=find(strcmpi(varargin,'low_frequency'));
    if isempty(a);
    else
        low_frequency=varargin{a+1};
    end;
    %high_frequency
    a=find(strcmpi(varargin,'high_frequency'));
    if isempty(a);
    else
        high_frequency=varargin{a+1};
    end;
    %num_frequency_lines
    a=find(strcmpi(varargin,'num_frequency_lines'));
    if isempty(a);
    else
        num_frequency_lines=varargin{a+1};
    end;
    %postprocess
    a=find(strcmpi(varargin,'postprocess'));
    if isempty(a);
    else
        postprocess=varargin{a+1};
    end;
    %average_epochs
    a=find(strcmpi(varargin,'average_epochs'));
    if isempty(a);
    else
        average_epochs=varargin{a+1};
    end;
    %segment_data
    a=find(strcmpi(varargin,'segment_data'));
    if isempty(a);
    else
        segment_data=varargin{a+1};
    end;
    %event_name
    a=find(strcmpi(varargin,'event_name'));
    if isempty(a);
    else
        event_name=varargin{a+1};
    end;
    %x_start
    a=find(strcmpi(varargin,'x_start'));
    if isempty(a);
    else
        x_start=varargin{a+1};
    end;
    %x_end
    a=find(strcmpi(varargin,'x_end'));
    if isempty(a);
    else
        x_end=varargin{a+1};
    end;
end;

%init message_string
message_string={};
message_string{1}='STFFT Zhang.';

out_header=header;

%update file type
%'amplitude','power','phase','complex'
switch postprocess;
    case 'amplitude'
        out_header.filetype='frequency_time_amplitude';
    case 'power'
        out_header.filetype='frequency_time_power';
    case 'phase'
        out_header.filetype='frequency_time_phase';
    case 'complex'
        out_header.filetype='frequency_time_complex';
end;


%freq_step, freq_start, freq_size
freq_step=(high_frequency-low_frequency)/num_frequency_lines;
freq_start=low_frequency;
freq_size=num_frequency_lines;

%time_step,time_start,time_size
time_step=header.xstep;
time_size=header.datasize(6);
time_start=header.xstart;

%update outheader YStep, YStart and YSize
out_header.ystep=freq_step;
out_header.ystart=freq_start;
out_header.datasize(5)=freq_size;

%update outheader XStep,XStart and XSize
out_header.xstep=time_step;
out_header.xstart=time_start;
out_header.datasize(6)=time_size;

%prepare xtimes
xtimes=0:out_header.datasize(6)-1;
xtimes=(xtimes*out_header.xstep)+out_header.xstart;

%prepare t
t=0:out_header.datasize(6)-1;
t=(t*out_header.xstep)+out_header.xstart;

%prepare f
f=0:out_header.datasize(5)-1;
f=(f*out_header.ystep)+out_header.ystart;

%prepare Fs
Fs=1/out_header.xstep;

%prepare winsize (in ms)
winsize=hanning_width*1000;

%prepare wintype
wintype='hann';

%prepare padvalue
padvalue='circular';

%convert to ms
xtimes=xtimes*1000;
t=t*1000;

%prepare out_data
dt=t(2)-t(1); % time interval (uniform step)
[junk,t_idx_min]=min(abs(xtimes-t(1)));
[junk,t_idx_max]=min(abs(xtimes-t(end)));
t_idx=t_idx_min:round((dt/1000)*Fs):t_idx_max;
N_T=length(t_idx);
out_header.datasize(6)=N_T;
out_data=zeros(out_header.datasize);
%adjust out_header.xstart and .xstep
out_header.xstart=t(1)/1000;
out_header.xstep=(t(2)-t(1))/1000;

%loop throuch channels
for chanpos=1:header.datasize(2);
    
    %loop through index
    for indexpos=1:header.datasize(3);
        
        message_string{end+1}=['C : ' num2str(chanpos) ' I : ' num2str(indexpos)];
                    
        %loop through dz
        for dz=1:header.datasize(4);
            
            %prepare x
            x=squeeze(data(:,chanpos,indexpos,dz,1,:))';
            
            %stfft
            [S,P]=sub_tfa_stft(x,xtimes,t,f,Fs,winsize,wintype,padvalue);
            S=permute(S,[3,1,2]);
            P=permute(P,[3,1,2]);
            
            switch postprocess
                case 'amplitude'
                    out_data(:,chanpos,indexpos,dz,:,:)=sqrt(P);
                case 'power'
                    out_data(:,chanpos,indexpos,dz,:,:)=P;
                case 'phase'
                    out_data(:,chanpos,indexpos,dz,:,:)=angle(P);
                case 'complex'
                    out_data(:,chanpos,indexpos,dz,:,:)=S;
            end;
            
        end;
    end;
end;

%segment if checked
if segment_data==1;
    k=1;
    message_string{end+1}='Attempting to segment the data.';
    event_idx=[];
    if isfield(header,'events');
        if isempty(header.events);
            if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Event field of dataset is empty! Skipping segmentation.',1,0); end;
        else
            %event_name
            event_name=event_name;
            message_string{end+1}='Segmenting continuous data into epochs.';
            message_string{end+1}=['Searching for event : ' event_name];
            %event_string, event_latency
            for i=1:length(header.events);
                event_string{i}=header.events(i).code;
            end;
            %find event_name in event_string
            a=find(strcmpi(event_name,event_string));
            if isempty(a);
                event_idx=[];
            else
                event_idx=a;
            end;
        end;
    else
        message_string{end+1}='No event field in the dataset! Skipping segmentation.';
    end;
    if isempty(event_idx);
        message_string{end+1}='No events found, saving continuous data.';
    else
        %corresponding events were found, so, we proceed
        message_string{end+1}=[num2str(length(event_idx)) ' corresponding events found in dataset.'];
        %adjust header
        %dxsize
        dxsize=fix((x_end-x_start)/header.xstep)+1;
        %set datasize
        out_header.datasize(1)=length(event_idx);
        out_header.datasize(6)=dxsize;
        %prepare out_data
        data=out_data;
        out_data=zeros(out_header.datasize);
        %initialize out_events
        k=1;
        out_events=header.events(1);
        %loop through events_latencies
        for i=1:length(event_idx);
            %dx1
            dx1=fix((((header.events(event_idx(i)).latency+x_start)-header.xstart)/header.xstep))+1;
            %dx2
            dx2=(dx1+dxsize)-1;
            %out_data > epoch(i)
            out_data(i,:,:,:,:,:)=data(header.events(event_idx(i)).epoch,:,:,:,:,dx1:dx2);
            %scan for events within epoch
            for j=1:length(header.events);
                %check epoch
                if header.events(j).epoch==header.events(event_idx(i)).epoch;
                    %new latency
                    new_latency=header.events(j).latency-header.events(event_idx(i)).latency;
                    %check if inside epoch limits
                    if new_latency>=x_start;
                        if new_latency<=(x_end);
                            %add event
                            out_events(k)=header.events(j);
                            out_events(k).latency=new_latency;
                            out_events(k).epoch=i;
                            k=k+1;
                        end;
                    end;
                end;
            end;
        end;
    end;
    
    %header.events
    if k==1;
        out_events=[];
    end;
    out_header.events=out_events;
    %delete epochdata
    if isfield(out_header,'epochdata');
        rmfield(out_header,'epochdata');
    end;
    
    %adjust header.xstart
    out_header.xstart=x_start;
end;

%average?
if average_epochs==1;
    message_string{end+1}='Averaging epochs';
    %change number of epochs to 1
    out_header.datasize(1)=1;
    %prepare data,out_data
    data=out_data;
    out_data=zeros(out_header.datasize);
    %PLV?
    if strcmpi(postprocess,'phase');
        %PLV
        message_string{end+1}='Average phase values selected.';
        message_string{end+1}='Will compute the Phase Locking Value (PLV).';
        %compute PLV
        x=sum(sin(out_data),1);
        y=sum(cos(out_data),1);
        out_data=sqrt(x.^2+y.^2);
        out_data=out_data/header.datasize(1);
    else
        %standard average
        out_data(:,:,:,:,:,:)=mean(data,1);
    end;
    %adjust events
    if isfield(out_header,'events');
        for event_pos=1:length(out_header.events);
            out_header.events(event_pos).epoch=1;
        end;
    end;
    %delete epochdata
    if isfield(out_header,'epochdata');
        rmfield(out_header,'epochdata');
    end;
end;


