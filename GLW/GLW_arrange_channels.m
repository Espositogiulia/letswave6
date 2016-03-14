function varargout = GLW_arrange_channels(varargin)
% GLW_ARRANGE_CHANNELS MATLAB code for GLW_arrange_channels.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_arrange_channels_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_arrange_channels_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT









% --- Executes just before GLW_arrange_channels is made visible.
function GLW_arrange_channels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_arrange_channels (see VARARGIN)
% Choose default command line output for GLW_arrange_channels
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%function('dummy',configuration,datasets);
%configuration
configuration=varargin{2};
set(handles.process_btn,'Userdata',configuration);
%datasets
datasets=varargin{3};
set(handles.prefix_edit,'Userdata',datasets);
%axis
axis off;
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%overwrite_chk Userdata stores status of ProcessBtn
set(handles.overwrite_chk,'Userdata',[]);
%ajust GUI according to configuration_mode
switch configuration.gui_info.configuration_mode
    case 'direct';
        set(handles.overwrite_chk,'Visible','on');
        set(handles.prefix_text,'Visible','on');
        set(handles.prefix_edit,'Visible','on');
        set(handles.process_btn,'String','Process');
    case 'script';
        set(handles.overwrite_chk,'Visible','off');
        set(handles.prefix_text,'Visible','off');
        set(handles.prefix_edit,'Visible','off');
        set(handles.process_btn,'String','Save');
    case 'history'
        set(handles.overwrite_chk,'Visible','off');
        set(handles.prefix_text,'Visible','off');
        set(handles.prefix_edit,'Visible','off');
        set(handles.process_btn,'Visible','off');
end;
%update prefix_edit
set(handles.prefix_edit,'String',configuration.gui_info.process_filename_string);
%update overwrite_chk
if strcmpi(configuration.gui_info.process_overwrite,'yes');
    set(handles.overwrite_chk,'Value',1);
else
    set(handles.overwrite_chk,'Value',0);
end;
%!!!!!!!!!!!!!!!!!!!!!!!!
%update GUI configuration
%!!!!!!!!!!!!!!!!!!!!!!!!
%header
header=datasets(1).header;
%channel_labels
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
%store channel_labels
set(handles.listbox1,'String',st);
%channel_idx
channel_idx=configuration.parameters.channel_idx;
set(handles.listbox2,'Userdata',channel_idx);
update_listbox2(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);







function update_listbox2(handles);
%channel_labels
channel_labels=get(handles.listbox1,'String');
%channel_idx
channel_idx=get(handles.listbox2,'Userdata');
st={};
if isempty(channel_idx);
else
    for i=1:length(channel_idx);
        st{i}=channel_labels{channel_idx(i)};
    end;
end;
set(handles.listbox2,'String',st);





% --- Outputs from this function are returned to the command line.
function varargout = GLW_arrange_channels_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;
%configuration
configuration=get(handles.process_btn,'UserData');
if isempty(get(handles.overwrite_chk,'Userdata'))
    varargout{2}=[];
else
   varargout{2}=configuration;
end;
delete(hObject);




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on selection change in filebox.
function filebox_Callback(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function filebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, eventdata, handles)
% hObject    handle to process_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%fetch configuration
configuration=get(handles.process_btn,'Userdata');
%notify that process_btn has been pressed
set(handles.overwrite_chk,'Userdata',1);
%prefix_edit
configuration.gui_info.process_filename_string=get(handles.prefix_edit,'String');
%overwrite_chk
if get(handles.overwrite_chk,'Value')==0;
    configuration.gui_info.process_overwrite='no';
else
    configuration.gui_info.process_overwrite='yes';
end;
%!!!!!!!!!!!!!!!!!!!!
%UPDATE CONFIGURATION
%!!!!!!!!!!!!!!!!!!!!
channel_idx=get(handles.listbox2,'Userdata');
configuration.parameters.channel_idx=channel_idx;
%!!!
%END
%!!!
%put back configuration
set(handles.process_btn,'Userdata',configuration);
close(handles.figure1);








% --- Executes on button press in overwrite_chk.
function overwrite_chk_Callback(hObject, eventdata, handles)
% hObject    handle to overwrite_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.overwrite_chk,'Value')==1;
    set(handles.prefix_text,'Visible','off');
    set(handles.prefix_edit,'Visible','off');
else
    set(handles.prefix_text,'Visible','on');
    set(handles.prefix_edit,'Visible','on');
end;
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%v
update_button_status(handles);




function update_button_status(handles);
v=get(handles.listbox2,'Value');
if isempty(v);
    set(handles.remove_btn,'Enable','off');
    set(handles.move_down_btn,'Enable','off');
    set(handles.move_up_btn,'Enable','off');
    set(handles.insert_btn,'Enable','off');
else
    if length(v)==1;
        set(handles.remove_btn,'Enable','on');
        set(handles.move_down_btn,'Enable','on');
        set(handles.move_up_btn,'Enable','on');
        set(handles.insert_btn,'Enable','on');
    else
        set(handles.remove_btn,'Enable','on');
        set(handles.move_down_btn,'Enable','off');
        set(handles.move_up_btn,'Enable','off');
        set(handles.insert_btn,'Enable','off');
    end;
end;





% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in insert_btn.
function insert_btn_Callback(hObject, eventdata, handles)
% hObject    handle to insert_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%channel_idx
channel_idx=get(handles.listbox2,'Userdata');
%selected_epochs
selected_epochs=get(handles.listbox1,'Value');
%insert_pos
insert_pos=get(handles.listbox2,'Value');
if isempty(insert_pos);
    insert_pos=1;
end;
%update channel_idx
if insert_pos==1;
    channel_idx=[selected_epochs channel_idx];
end;
if insert_pos==length(channel_idx);
    channel_idx=[channel_idx selected_epochs];
end;
if (insert_pos>1)&(insert_pos<length(channel_idx));
    channel_idx=[channel_idx(1:insert_pos-1) selected_epochs channel_idx(insert_pos:end)];
end;
set(handles.listbox2,'Userdata',channel_idx);
update_listbox2(handles);






% --- Executes on button press in add_top_btn.
function add_top_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_top_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%channel_idx
channel_idx=get(handles.listbox2,'Userdata');
%selected_epochs
selected_epochs=get(handles.listbox1,'Value');
%update channel_idx
channel_idx=[selected_epochs channel_idx];
set(handles.listbox2,'Userdata',channel_idx);
update_listbox2(handles);






% --- Executes on button press in add_bottom_btn.
function add_bottom_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_bottom_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%channel_idx
channel_idx=get(handles.listbox2,'Userdata');
%selected_epochs
selected_epochs=get(handles.listbox1,'Value');
%update channel_idx
channel_idx=[channel_idx selected_epochs];
set(handles.listbox2,'Userdata',channel_idx);
update_listbox2(handles);






% --- Executes on button press in sort_ascending_btn.
function sort_ascending_btn_Callback(hObject, eventdata, handles)
% hObject    handle to sort_ascending_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%insert_idx
insert_idx=get(handles.listbox2,'Userdata');
insert_idx=sort(insert_idx);
set(handles.listbox2,'Userdata',insert_idx);
update_listbox2(handles);





% --- Executes on button press in sort_descending_btn.
function sort_descending_btn_Callback(hObject, eventdata, handles)
% hObject    handle to sort_descending_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
insert_idx=get(handles.listbox2,'Userdata');
insert_idx=sort(insert_idx,'descend');
set(handles.listbox2,'Userdata',insert_idx);
update_listbox2(handles);






% --- Executes on button press in remove_btn.
function remove_btn_Callback(hObject, eventdata, handles)
% hObject    handle to remove_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%insert_idx
insert_idx=get(handles.listbox2,'Userdata');
%v
v=get(handles.listbox2,'Value');
%delete
insert_idx(v)=[];
%update
set(handles.listbox2,'Userdata',insert_idx);
update_listbox2(handles);
set(handles.listbox2,'Value',[]);
update_button_status(handles);





% --- Executes on button press in add_all_btn.
function add_all_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_all_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%st > channel_idx
st=get(handles.listbox1,'String');
channel_idx=1:1:length(st);
set(handles.listbox2,'Userdata',channel_idx);
update_listbox2(handles);





% --- Executes on button press in remove_all_btn.
function remove_all_btn_Callback(hObject, eventdata, handles)
% hObject    handle to remove_all_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.listbox2,'Userdata',[]);
update_listbox2(handles);
set(handles.listbox2,'Value',[]);
update_button_status(handles);




% --- Executes on button press in select_odd_btn.
function select_odd_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_odd_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st=get(handles.listbox1,'String');
idx=1:2:length(st);
set(handles.listbox1,'Value',idx);





% --- Executes on button press in select_even_btn.
function select_even_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_even_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st=get(handles.listbox1,'String');
idx=2:2:length(st);
set(handles.listbox1,'Value',idx);






% --- Executes on button press in move_up_btn.
function move_up_btn_Callback(hObject, eventdata, handles)
% hObject    handle to move_up_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%insert_idx
insert_idx=get(handles.listbox2,'Userdata');
%insert_pos
insert_pos=get(handles.listbox2,'Value');
if isempty(insert_pos);
else
    if insert_pos>1;
        tp=insert_idx(insert_pos-1);
        insert_idx(insert_pos-1)=insert_idx(insert_pos);
        insert_idx(insert_pos)=tp;
        set(handles.listbox2,'Userdata',insert_idx);
        insert_pos=insert_pos-1;
        set(handles.listbox2,'Value',insert_pos);
        update_listbox2(handles);
    end;
end;




% --- Executes on button press in move_down_btn.
function move_down_btn_Callback(hObject, eventdata, handles)
% hObject    handle to move_down_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%insert_idx
insert_idx=get(handles.listbox2,'Userdata');
%insert_pos
insert_pos=get(handles.listbox2,'Value');
if isempty(insert_pos);
else
    if insert_pos<length(insert_idx);
        tp=insert_idx(insert_pos+1);
        insert_idx(insert_pos+1)=insert_idx(insert_pos);
        insert_idx(insert_pos)=tp;
        set(handles.listbox2,'Userdata',insert_idx);
        insert_pos=insert_pos+1;
        set(handles.listbox2,'Value',insert_pos);
        update_listbox2(handles);
    end;
end;
