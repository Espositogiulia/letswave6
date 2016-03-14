function [out_configuration,out_datasets] = LW_merge_channels(operation,configuration,datasets,update_pointers)
% LW_merge_channels
% Merge channels of multiple datasets
%
% operations : 
% 'gui_info'
% 'default'
% 'process'
% 'configure'
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


%argument parsing
if nargin<1;
    error('operation is a required argument');
end;
if nargin<2;
    configuration=[];
end;
if nargin<3;
    datasets=[];
end;
if nargin<4;
    update_pointers=[];
end;

%gui_info
gui_info.function_name='LW_merge_channels';
gui_info.name='Merge channels of multiple datasets';
gui_info.description='Merge channels of multiple datasets.';
gui_info.parent='arrange_signals_menu';
gui_info.scriptable='no';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='yes';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='merged_channels';         %default filename suffix (or filename (if 'unique'))
gui_info.process_overwrite='no';                %process should overwrite the original dataset?


%operation
switch operation
    
    case 'gui_info'
        %configuration
        out_configuration=configuration;
        out_configuration.gui_info=gui_info;
        %datasets
        out_datasets=datasets;
        
    case 'default'
        %configuration
        out_configuration=configuration;
        out_configuration.gui_info=gui_info;
        out_configuration.parameters.merge_idx=[];
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Merge channels of different datasets.',1,0); end;
        %process
        [out_datasets.header,out_datasets.data,message_string]=RLW_merge_channels(datasets,configuration.parameters.merge_idx);
        %message_string
        if isempty(update_pointers);
        else
            if isempty(message_string);
            else
                for i=1:length(message_string);
                    update_pointers.function(update_pointers.handles,message_string{i},1,0);
                end;
            end;
        end;
        %add configuration to history
        if isempty(out_datasets.header.history);
            out_datasets.header.history(1).configuration=configuration;
        else
            out_datasets.header.history(end+1).configuration=configuration;
        end;
        %update header.name
        if strcmpi(configuration.gui_info.process_overwrite,'no');
            out_datasets.header.name=[configuration.gui_info.process_filename_string];
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;
        
        
        
        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_merge_channels('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
