% -----------------------------------
% General Rules
% -----------------------------------

% Boiler -->

has_base(X,COMP):-connection(X), has_connected_component(X,COMP,0).

connection_point(POINT) :- screw_point(POINT) .

connection(X) :- screw_connection(X) .
connection(X) :- screw_clamp_connection(X) .
connection(X) :- plugin_connection(X) .
connection(X) :- welding_connection(X) .
connection(X) :- glue_connection(X) .
connection(X) :- push_connection(X).
connection(X) :- coat_requirement(X).

connection(X) :- drill_requirement(X).
requirement(X):-drill_requirement(X).

component(X) :- has_connected_component(_,X,_).
component(X) :- has_processed_component(_,X).
component(X) :- assembly_component(X) .
component(X) :- screw(X) .
component(X) :- nut(X) .
component(X) :- washer(X) .

component_connection(COMP,CONN) :- component(COMP), has_connected_component(CONN,COMP,_) .
component_connection_count(COMP,COUNT) :- component(COMP), COUNT = #count{CONN : component_connection(COMP,CONN)} .
component_connection_step(COMP,CONN,STEP) :- component_connection(COMP,CONN), plan_connection(CONN,STEP) .
component_first_connection(COMP,CONN) :- MIN = #min{STEP : component_connection_step(COMP,_,STEP)}, component_connection_step(COMP,CONN,MIN) .

washer(X) :- spring_washer(X) .
srew(X) :- hex_head_screw(X) .
nut(X) :- hex_nut(X) .

tool("Socket Wrench",tool_id_wrench).
tool("Screw Driver Default",tool_id_default).
tool("Screw Driver Slotted",tool_id_slotted).
tool("Screw Driver Hex",tool_id_hex).
tool("Screw Driver Philips",tool_id_philips).
tool("Hand",tool_id_hand).


%tool(X) :- screw_driver(X) .
%tool(X) :- wrench(X) .

%Define default screwing tools according to screw head type
is_for("Hand",SCREW) :-  screw(SCREW), has_head(SCREW,_,"hand_grip") .
is_for("Socket Wrench",SCREW) :- tool("Socket Wrench",_), screw(SCREW), has_head(SCREW,_,"hex") .
is_for("Socket Wrench",NUT) :- tool("Socket Wrench",_), nut(NUT), has_shape(NUT,"hex") .
is_for("Screw Driver Philips",SCREW) :- tool("Screw Driver Philips",_),screw(SCREW), has_head(SCREW,_,"pan_head") .
is_for("Screw Driver Slotted",SCREW) :- tool("Screw Driver Slotted",_),screw(SCREW), has_head(SCREW,_,"cheese_head") .
is_for("Screw Driver Hex",SCREW) :- tool("Screw Driver Hex",_),screw(SCREW), has_head(SCREW,_,"button_head") .
is_for("Screw Driver Hex",SCREW) :- tool("Screw Driver Hex",_),screw(SCREW), has_head(SCREW,_,"cap_head") .

%torque_with("m6","2","Nm") .
%torque_with("4.2","1.5","Nm") .

has_component(X,COMP) :- has_screw(X,COMP) .
has_component(X,COMP) :- has_nut(X,COMP) .
has_component(X,COMP) :- has_washer(X,COMP) .

component(COMP) :- has_matching(X,COMP,Y) .


% Rules for additional operation information
% The needed instance informations are defined in components.lp
% ----------------------------------

%if no is_for is assigned to that screw use default screw driver
tighten_with(CONN,STEP,COMP,id_default) :- action(tighten,CONN,POINT,COMP,STEP),default_tool("Screw Driver Default",id_default), tool(TOOL,ID), not is_for(TOOL,COMP), not tighten_with(CONN,STEP,COMP,_,_,_) .
%else assign according tool from is_for
tighten_with(CONN,STEP,COMP,ID,SIZE,none) :- action(tighten,CONN,POINT,COMP,STEP), is_for(TOOL,COMP), not is_for("Hand",COMP), tool(TOOL,ID), has_head(COMP,SIZE,_).
tighten_with(CONN,STEP,COMP,ID,none,none) :- action(tighten,CONN,POINT,COMP,STEP), is_for("Hand",COMP), has_head(COMP,_,_),tool("Hand",ID).
tighten_with(CONN,STEP,COMP,ID,VALUE,UNIT) :- action(tighten,CONN,POINT,COMP,STEP), tool(TOOL,ID), is_for(TOOL,COMP), has_thread(COMP,TYPE,"mm"), torque_with(TYPE,VALUE,UNIT) .



#show tighten_with/4 .
#show tighten_with/6 .
position_on(CONN,STEP,COMP,OBJ,COMP_B,OBJ_B) :- action(position,CONN,POINT,COMP,STEP), has_matching(POINT,COMP,OBJ), has_matching(POINT,COMP_B,OBJ_B), COMP != COMP_B .
position_on(CONN,STEP,COMP,COMP,OBJ_B,OBJ_B) :- action(position,CONN,POINT,COMP,STEP), has_washer(POINT,COMP), has_screw(POINT,OBJ_B), screw(OBJ_B), COMP != OBJ_B, not has_matching(POINT,OBJ_B,_) .
position_with(CONN,STEP,COMP,"Hand") :- action(position,CONN,_,COMP,STEP) .
position_with(CONN,STEP,COMP,"2AK") :- action(position,CONN,_,COMP,STEP), weight(COMP,X), X>100 .
position_with(CONN,STEP,COMP,"2AK") :- action(position,CONN,_,COMP,STEP), sizw(COMP,X), X>100 .
#show position_on/6 .
#show position_with/4 .

insert_with(CONN,STEP,COMP,OBJ,"Hand") :- action(insert,CONN,POINT,COMP,STEP), has_screw(POINT,COMP), has_matching(POINT,_,COMP), has_matching(POINT,_,OBJ), COMP != OBJ .
insert_with(CONN,STEP,COMP,OBJ,"Hand") :- action(insert,CONN,POINT,COMP,STEP), has_screw(POINT,COMP), not has_matching(POINT,_,COMP), has_matching(POINT,_,OBJ), COMP != OBJ .
#show insert_with/5 .

adjust_with(CONN,STEP,COMP,"Hand") :- action(adjust,CONN,_,COMP,STEP) .
#show adjust_with/4 .

turnon_with(CONN,STEP,COMP,SCREW,"Hand") :- action(turnon,CONN,PONIT,COMP,STEP), has_nut(POINT,COMP), has_screw(POINT,SCREW) .
%#show turnon_with/5 .

sub_action(CONN, STEP,0,COMP_1,COMP_2,POINT, "plug in") :- action(plugin,CONN,COMP_1,COMP_2,STEP), has_connection_point(CONN,POINT).
plugin_with(CONN,STEP,COMP_2,"Hand") :- action(plugin,CONN,_,COMP_2,STEP) .
#show plugin_with/4 .

% <-- Boiler

% -----------------------------------
% Processing Rules
% -----------------------------------

%in every step handle exactly one connection
connection_step(0..END-1) :- END = #count{CONN: connection(CONN)} .

1{plan_connection(CONN,STEP): connection(CONN)}1 :- connection_step(STEP) .

:- plan_connection(CONN,STEP_A), plan_connection(CONN,STEP_B), STEP_A != STEP_B .
:- plan_connection(CONN_A,STEP_A), plan_connection(CONN_B,STEP_B),plan_connection(CONN_C,STEP_C), component_connect_connections_together(COMP,ID,CONN_A),
						component_connect_connections_together(COMP,ID,CONN_B),component_connect_connections_together(COMP_C,ID_C,CONN_C),
						COMP_C != COMP, STEP_A < STEP_C, STEP_C < STEP_B .
:- plan_connection(CONN,STEP), start_connection(CONN), STEP > 0 .

%action(assemble,CONN,A,B,STEP) :- plan_connection(CONN,STEP), not requirement(CONN), has_connected_component(CONN,A,_),has_connected_component(CONN,B,_), A!=B, not action(assemble,CONN,B,A,_) . 
%action(assemble,CONN,A,none,STEP) :- plan_connection(CONN,STEP), not requirement(CONN), has_connected_component(CONN,A,_), #count{P : has_connected_component(CONN,P,_)} = 1. 

%:- action(assemble,CONN,A,B,_),action(assemble,CONN,A2,B2,_),(A,B) != (A2,B2).

action(assemble,CONN,A,B,STEP) :-
    plan_connection(CONN,STEP),
    not requirement(CONN),
    has_connected_component(CONN,A,_),
    has_connected_component(CONN,B,_),
    A < B.

action(assemble,CONN,A,none,STEP) :-
    plan_connection(CONN,STEP),
    not requirement(CONN),
    has_connected_component(CONN,A,_),
    #count{P : has_connected_component(CONN,P,_)} = 1.

:- action(assemble,CONN,A,B,_),
   action(assemble,CONN,A2,B2,_),
   (A,B) != (A2,B2).

action(execute,CONN,none,none,STEP) :- plan_connection(CONN,STEP), requirement(CONN) . 


% Action Rules
% -----------------------------------

action(ACTION,CONN,A,B,SUM + 1 + SUB_STEP) :- action(ACTION,CONN,A,B,STEP_A,SUB_STEP), SUM = #sum{S,STEP : sub_actions(CONN,STEP,S), STEP < STEP_A} .
optional_info(CONN,SUM + 1 + SUB_STEP,"optional") :- optional_info(CONN,_,STEP_A,SUB_STEP), SUM = #sum{S,STEP : sub_actions(CONN,STEP,S), STEP < STEP_A} .

% -----------------------------------
% RESULT Filters
% -----------------------------------

%#show connection/1 .

%#show action/6 .
#show action/5 .
#show optional_info/3 .




%:Screw_Planning_LP a asp:RuleSet;

% -----------------------------------
% Processing Rules
% -----------------------------------

screw_connection_start(CONN,END) :- screw_connection(CONN), END = 0 .
screw_connection_end(CONN,END) :- screw_tighten_end(CONN,END) .

% Position Components Planning Rules
% -----------------------------------

screw_assemble_start(CONN,STEP) :- screw_connection_start(CONN,STEP) .
screw_step(CONN,screw_assemble_step(START..COUNT)) :- screw_assemble_start(CONN,START),COUNT == 0, COUNT = #count{COMP : has_connected_component(CONN,COMP,ORDER), ORDER != 0} .
screw_assemble_end(CONN,COUNT) :- screw_assemble_start(CONN,STEP), COUNT == 0, COUNT = #count{COMP : has_connected_component(CONN,COMP,ORDER), ORDER != 0}.

position_screwing_component(CONN,COMP_A,COMP_B,STEP,SUB_STEP) :- screw_step(CONN,screw_assemble_step(STEP)), 
												has_connected_component(CONN,COMP_A,SUB_STEP-1), 
												has_connected_component(CONN,COMP_B,SUB_STEP),
												has_screw_hole(COMP_A,X),has_screw_hole(COMP_B,X),
												has_connection_point(CONN,X),
												component_first_connection(COMP_B,CONN) .
	

%#show position_screwing_component/5 .	

action(position,CONN_A,COMP_A,COMP_B,STEP,SUB_STEP-1) :- position_screwing_component(CONN_A,COMP_A,COMP_B,STEP,SUB_STEP-1) .

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), screw_step(CONN,screw_assemble_step(STEP))}, screw_step(CONN,screw_assemble_step(STEP)) .


% Screw Point Planning Rules
% -----------------------------------

screw_insert_start(CONN,STEP) :- screw_assemble_end(CONN,STEP) .
screw_insert_start(CONN,STEP) :- not screw_assemble_end(CONN,STEP), screw_connection_start(CONN,STEP) .
screw_step(CONN,screw_insert_step(START..START+END-1)) :- screw_insert_start(CONN,START), END = #count{POINT : has_connection_point(CONN,POINT)} .
screw_insert_end(CONN,STEP+COUNT) :- screw_insert_start(CONN,STEP), COUNT = #count{POINT : has_connection_point(CONN,POINT)}.

1{screw_action(POINT,CONN,STEP): has_connection_point(CONN,POINT)}1 :- screw_step(CONN,screw_insert_step(STEP)) .
:- screw_action(POINT,CONN,STEP_A), screw_action(POINT,CONN,STEP_B), STEP_A != STEP_B .


%if has washer, no plugin nut
action(position_washer,CONN,POINT,COMP,STEP,0) :- screw_action(POINT,CONN,STEP), has_washer(POINT,COMP), not has_pluginnut(POINT,_) .
action(insert,CONN,POINT,COMP,STEP,1) :- screw_action(POINT,CONN,STEP), has_screw(POINT,COMP), has_washer(POINT,_), not has_pluginnut(POINT,_)  .
%if has nut
action(turnon,CONN,POINT,COMP,STEP,2) :- screw_action(POINT,CONN,STEP), has_nut(POINT,COMP), has_washer(POINT,_), not has_pluginnut(POINT,_) .

%if has plugin nut, no washer
action(position_pluginnut,CONN,POINT,NUT,STEP,0) :- screw_action(POINT,CONN,STEP), has_pluginnut(POINT,NUT), has_screw(POINT,COMP), not has_washer(POINT,_) .
action(insert,CONN,POINT,COMP,STEP,1) :- screw_action(POINT,CONN,STEP),has_pluginnut(POINT,NUT), has_screw(POINT,COMP), not has_washer(POINT,_)  .
%if has nut
action(turnon,CONN,POINT,COMP,STEP,2) :- screw_action(POINT,CONN,STEP),has_pluginnut(POINT,NUT), has_nut(POINT,COMP), not has_washer(POINT,_) .


%if has washer, has plugin nut
action(position_washer,CONN,POINT,COMP,STEP,0) :- screw_action(POINT,CONN,STEP), has_pluginnut(POINT,NUT), has_washer(POINT,COMP) .
action(position_pluginnut,CONN,POINT,NUT,STEP,1) :- screw_action(POINT,CONN,STEP), has_pluginnut(POINT,NUT), has_screw(POINT,COMP), has_washer(POINT,_) .
action(insert,CONN,POINT,COMP,STEP,2) :- screw_action(POINT,CONN,STEP),has_pluginnut(POINT,NUT), has_screw(POINT,COMP), has_washer(POINT,_) .
%if has nut
action(turnon,CONN,POINT,COMP,STEP,3) :- screw_action(POINT,CONN,STEP),has_pluginnut(POINT,NUT), has_nut(POINT,COMP), has_washer(POINT,_) .


%if no washer, no plugin nut
action(insert,CONN,POINT,COMP,STEP,0) :- screw_action(POINT,CONN,STEP), has_screw(POINT,COMP), not has_washer(POINT,_), not has_pluginnut(POINT,_) .
%if has nut
action(turnon,CONN,POINT,COMP,STEP,1) :- screw_action(POINT,CONN,STEP), has_nut(POINT,COMP), not has_washer(POINT,_), not has_pluginnut(POINT,_)  .




sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y)}, screw_step(CONN,screw_insert_step(STEP)) .


% Adjust Planning Rules
% -----------------------------------
screw_adjust_start(CONN,STEP+1) :- screw_insert_end(CONN,STEP) .
screw_step(CONN,screw_adjust_step(START..START+END-1)) :- screw_adjust_start(CONN,START), END = #count{COMP : has_connected_component(CONN,COMP,_)} .
screw_adjust_end(CONN,STEP+COUNT) :- screw_adjust_start(CONN,STEP), COUNT = #count{COMP : has_connected_component(CONN,COMP,_)} .

1{adjust_action(none,CONN,COMP,STEP,0): has_connected_component(CONN,COMP,_)}1 :- screw_step(CONN,screw_adjust_step(STEP)) .

:- adjust_action(POINT,CONN,COMP,STEP_A,0), adjust_action(POINT,CONN,COMP,STEP_B,0), STEP_A != STEP_B .

%if the component is a design part or the hole is a longhole adjust
action(adjust,CONN,POINT,COMP,STEP,0) :- adjust_action(POINT,CONN,COMP,STEP,0), has_hole(COMP,_,"longhole").
action(adjust,CONN,POINT,COMP,STEP,0) :- adjust_action(POINT,CONN,COMP,STEP,0), design_part(COMP).

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y)}, screw_step(CONN,screw_adjust_step(STEP)) .


% Tighten Planning Rules
% -----------------------------------
screw_tighten_start(CONN,STEP+1) :- screw_adjust_end(CONN,STEP) .
screw_step(CONN,screw_tighten_step(START..START+END-1)) :- screw_tighten_start(CONN,START), END = #count{POINT : has_connection_point(CONN,POINT)} .
screw_tighten_end(CONN,STEP+COUNT) :- screw_tighten_start(CONN,STEP), COUNT = #count{POINT : has_connection_point(CONN,POINT)}.

1{tighten_action(POINT,CONN,STEP,0): has_connection_point(CONN,POINT)}1 :- screw_step(CONN,screw_tighten_step(STEP)) .

:- tighten_action(POINT,CONN,STEP_A,0), tighten_action(POINT,CONN,STEP_B,0), STEP_A != STEP_B .

%either tighten nut (if there is a nut) or tighten screw 
action(tighten,CONN,POINT,COMP,STEP,0) :- tighten_action(POINT,CONN,STEP,0), has_screw(POINT,COMP), not has_nut(POINT,_).
action(tighten,CONN,POINT,COMP,STEP,0) :- tighten_action(POINT,CONN,STEP,0), has_nut(POINT,COMP).

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y)}, screw_step(CONN,screw_tighten_step(STEP)) .



%:Glue_Planning_LP a asp:RuleSet;


% -----------------------------------
% Processing Rules
% -----------------------------------

glue_connection_start(CONN,END+1) :- glue_connection(CONN), END = 0 .
glue_connection_end(CONN,END) :- glue_stick_on_end(CONN,END) .


% Prepare Rules
% -----------------------------------
% NOTE: for Liquid and Tape both components have to be prepared, for self adhesive only the base part has to be prepared
% -----------------------------------

glue_prepare_start(CONN,STEP):-glue_connection_start(CONN,STEP).
%create a glue step for preparing for every component in the connection
glue_step(CONN,glue_prepare_step(START..START+COUNT-1)) :- glue_prepare_start(CONN,START), not glue_type(CONN, "self adhesive"), COUNT = #count{COMP : has_connected_component(CONN,COMP,_)} .
glue_step(CONN,glue_prepare_step(START..START)) :- glue_prepare_start(CONN,START), glue_type(CONN, "self adhesive") .
glue_prepare_end(CONN, STEP+COUNT) :- glue_prepare_start(CONN, STEP), COUNT = #count{COMP : has_connected_component(CONN,COMP,_)}.

%per glue step assign exactly one component to be handled in glue action
1{glue_action(CONN,COMP,STEP): has_connected_component(CONN,COMP,_)}1 :- glue_step(CONN,glue_prepare_step(STEP)), not glue_type(CONN, "self adhesive") .
glue_action(CONN,COMP,STEP) :- glue_step(CONN,glue_prepare_step(STEP)),has_connected_component(CONN,COMP,0),glue_type(CONN,"self adhesive") .
%constraint: one glue action handling the same component cannot occure in different time steps
:- glue_action(CONN,COMP,STEP_A), glue_action(CONN,COMP,STEP_B), STEP_A != STEP_B .

%defining actions with according sub step - glue connection with liquid glue
action(grind,CONN,COMP,none,STEP,0)  :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
	optional_info(CONN,COMP,STEP,0)  :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
action(clean,CONN,COMP,none,STEP,1) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
action(mask,CONN,COMP,none,STEP,2) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
	optional_info(CONN,COMP,STEP,2) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
action(prime,CONN,COMP,none,STEP,3) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
	optional_info(CONN,COMP,STEP,3) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .

%defining actions with according sub step - glue connection with other than liquid glue
action(clean,CONN,COMP,none,STEP,0) :- glue_action(CONN,COMP,STEP), not glue_type(CONN, "liquid") .
action(prime,CONN,COMP,none,STEP,1) :- glue_action(CONN,COMP,STEP), not glue_type(CONN, "liquid") .
	optional_info(CONN,COMP,STEP,1) :- glue_action(CONN,COMP,STEP), not glue_type(CONN, "liquid") .
%counting number of sub actions 
sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), glue_step(CONN,glue_prepare_step(STEP))}, glue_step(CONN,glue_prepare_step(STEP)) .


% Prepare Adhesive Rules
% -----------------------------------

glue_prepare_adhesive_start(CONN,STEP):-glue_prepare_end(CONN,STEP).
glue_step(CONN, glue_prepare_adhesive_step(STEP..STEP)):-glue_prepare_adhesive_start(CONN,STEP).
glue_prepare_adhesive_end(CONN, STEP+1) :- glue_prepare_adhesive_start(CONN, STEP).

prepare_adhesive(CONN,COMP_A,COMP_B,STEP):- glue_step(CONN, glue_prepare_adhesive_step(STEP)), has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1).

action(equip_glue_equipment,CONN,COMP_A,COMP_B,STEP,0):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid").

action(remove_film,CONN,COMP_A,COMP_B,STEP,0):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive"),has_connected_component(CONN,COMP_B,1), not sticker(COMP_B) .
%if the self adhesive part is a sticker or label it may have to be cut to length first
action(cut_to_length,CONN,COMP_A,COMP_B,STEP,0):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive"), has_connected_component(CONN,COMP_B,1), sticker(COMP_B) .
action(remove_film,CONN,COMP_A,COMP_B,STEP,1):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive"),has_connected_component(CONN,COMP_B,1), sticker(COMP_B) .


action(cut_to_length,CONN,COMP_A,COMP_B,STEP,0):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "tape") .
action(remove_film,CONN,COMP_A,COMP_B,STEP,1):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "tape") .

%counting number of sub actions 
sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), glue_step(CONN,glue_prepare_adhesive_step(STEP))}, glue_step(CONN,glue_prepare_adhesive_step(STEP)) .


% Apply Adhesive Rules
% -----------------------------------

glue_apply_adhesive_start(CONN,STEP):- glue_prepare_adhesive_end(CONN,STEP), not glue_type(CONN, "self adhesive"). 
%one glue step per connection point
glue_step(CONN, glue_apply_adhesive_step(STEP..STEP+COUNT-1)):- glue_apply_adhesive_start(CONN,STEP), COUNT = #count{POINT : has_connection_point(CONN,POINT)}.
glue_apply_adhesive_end(CONN, STEP+COUNT) :- glue_apply_adhesive_start(CONN, STEP), COUNT = #count{POINT : has_connection_point(CONN,POINT)}.

1{apply_adhesive(CONN,POINT,STEP): has_connection_point(CONN,POINT)}1 :- glue_step(CONN, glue_apply_adhesive_step(STEP)).
:- apply_adhesive(CONN,POINT,STEP_A), apply_adhesive(CONN,POINT,STEP_B), STEP_A != STEP_B .
apply_adhesive(CONN,COMP_A,POINT,STEP):- apply_adhesive(CONN,POINT,STEP), has_connected_component(CONN,COMP_A,0).

%for liquid, apply adhesive for every point 
action(apply_glue,CONN,COMP,POINT,STEP,0) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "liquid" ).
%if glue point is an area, glue as to be spread
action(spread_glue,CONN,COMP,POINT,STEP,1) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP,STEP,1) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "liquid" ).


%double sided tape, apply tape on base and remove film on other side
action(apply_tape,CONN,COMP,POINT,STEP,0) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "tape" ) .
action(remove_film,CONN,COMP,POINT,STEP,1) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "tape" ) .

%counting number of sub actions 
sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), glue_step(CONN,glue_apply_adhesive_step(STEP))}, glue_step(CONN,glue_apply_adhesive_step(STEP)) .


% Stick On Rules
% -----------------------------------
	
glue_stick_on_start(CONN,STEP) :- glue_apply_adhesive_end(CONN,STEP), not glue_type(CONN, "self adhesive").
glue_stick_on_start(CONN,STEP) :- glue_prepare_adhesive_end(CONN,STEP), glue_type(CONN, "self adhesive").
glue_step(CONN, glue_stick_on_step(STEP..STEP)):- glue_stick_on_start(CONN,STEP).
glue_stick_on_end(CONN, STEP+1) :- glue_stick_on_start(CONN, STEP).

stick_on_part(CONN,COMP_A,COMP_B,STEP):- glue_step(CONN, glue_stick_on_step(STEP)), has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1).

action(stick_on,CONN,COMP_A,COMP_B,STEP,0):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
action(remove_excess_glue,CONN,COMP_A,COMP_B,STEP,1) :- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP_A,STEP,1) :- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
%remove masking tape that was applied in prepare step
action(remove_tape,CONN,COMP_A,COMP_B,STEP,2):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP_A,STEP,2):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
action(fix_with_equipment,CONN,COMP_A,COMP_B,STEP,3) :- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP_A,STEP,3):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
action(remove_equipment,CONN,COMP_A,COMP_B,STEP,4) :- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP_A,STEP,4):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).

action(stick_on,CONN,COMP_A,COMP_B,STEP,0):-stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive").
%in case the self adhesive part is a sticker or label smoothen it after sticking on
action(smoothen,CONN,COMP_A,COMP_B,STEP,1) :-stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive"), sticker(COMP_B) .


action(stick_on,CONN,COMP_A,COMP_B,STEP,0):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "tape" ).

%counting number of sub actions 
sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), glue_step(CONN,glue_stick_on_step(STEP))}, glue_step(CONN,glue_stick_on_step(STEP)) .
