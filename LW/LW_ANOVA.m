function [out_configuration,out_datasets] = LW_ANOVA(operation,configuration,datasets,update_pointers)
% LW_ANOVA
% Compare more than two datasets (ANOVA)
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
gui_info.function_name='LW_ANOVA';
gui_info.name='Compare more than two datasets (ANOVA)';
gui_info.description='Compare more than two datasets (ANOVA).';
gui_info.parent='stats_menu';
gui_info.scriptable='no';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string={'anova_F_values' 'anova_p_values'};       %default filename suffix (or filename(s) (if 'unique'))
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
        out_configuration.parameters.factor_data=[];
        out_configuration.parameters.table_data=[];
        out_configuration.parameters.enable_parallel=0;
        out_configuration.parameters.alpha=0.05;
        out_configuration.parameters.permutation=0;
        out_configuration.parameters.num_permutations=250;
        out_configuration.parameters.cluster_statistic='perc_mean'; %'perc_mean' 'perc_max' 'sd_mean' 'sd_max'
        out_configuration.parameters.cluster_threshold=95;
        %datasets
        out_datasets=datasets;
        
    case 'process'
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** ANOVA. This may take a while!',1,0); end;        
        %process
        [out_datasets(1),out_datasets(2),message_string,cluster_distribution]=RLW_ANOVA(datasets,configuration.parameters.factor_data,configuration.parameters.table_data,'enable_parallel',configuration.parameters.enable_parallel,'alpha',configuration.parameters.alpha,'permutation',configuration.parameters.permutation,'num_permutations',configuration.parameters.num_permutations,'cluster_statistic',configuration.parameters.cluster_statistic,'cluster_threshold',configuration.parameters.cluster_threshold);
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
        %add cluster distribution to configuration
        configuration.parameters.cluster_distribution=cluster_distribution;
        %add configuration to history
        for i=1:2;
            if isempty(out_datasets(i).header.history);
                out_datasets(i).header.history(1).configuration=configuration;
            else
                out_datasets(i).header.history(end+1).configuration=configuration;
            end;
        end;
        %update header.name
        out_datasets(1).header.name=configuration.gui_info.process_filename_string{1};
        out_datasets(2).header.name=configuration.gui_info.process_filename_string{2};
        %
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;
        
        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_ANOVA('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;

end;
