function [Low_tracks_out] = TrackletsMergeTiny_V1(Low_tracks_in,ObjN,ThreSeg,ThreSegRatio)
%  寻找一段被认为tiny的轨迹，删除
%  满足条件：1）长度<=ThreSeg(*2)；2,3）左右ThreSeg*2范围处，存在ObjN条以上轨迹长ThreSeg*6的轨迹
%  Low_tracks_in  |  input tracelets
%  ObjN  |  number of objects
%  ThreSeg  |  长度阈值
%  ThreSegRatio(1,2)  |  （覆盖端点阈值，长度阈值）
%  -----------------------------------------
% ThreSegRatio=[1.2 2 6];

TR_SE=[Low_tracks_in(:).StartEnd]';
TR_SE=double(TR_SE);
Low_tracks_dura=TR_SE(:,2)-TR_SE(:,1);

TR_ind_1=find(Low_tracks_dura<=ThreSeg*ThreSegRatio(1));  % 准备删除的轨迹 | 长度小于ThreSeg
TR_ind_2=Low_tracks_dura>=ThreSeg*ThreSegRatio(3);  % 长度大于ThreSeg*6的轨迹
TR_ind_2_SE=TR_SE(TR_ind_2,:);

Flag=zeros(length(TR_ind_1),2);
for ci=1:length(TR_ind_1)
    TR1=Low_tracks_in(TR_ind_1(ci)).StartEnd;
    TR1=[TR1(1)-ThreSeg*ThreSegRatio(2) TR1(2)+ThreSeg*ThreSegRatio(2)];
    TR2_1=TR_ind_2_SE(:,1)<=TR1(1);
    TR2_2=TR_ind_2_SE(:,2)>=TR1(1);
    TR2=TR2_1.*TR2_2;
    Flag(ci,1)=sum(TR2)>=ObjN;
    
    TR2_1=TR_ind_2_SE(:,1)<=TR1(2);
    TR2_2=TR_ind_2_SE(:,2)>=TR1(2);
    TR2=TR2_1.*TR2_2;
    Flag(ci,2)=sum(TR2)>=ObjN;
end
FlagDel=Flag(:,1).*Flag(:,2);
% Low_tracks_Del=Low_tracks_in(TR_ind_1(FlagDel==1));
Low_tracks_out=Low_tracks_in;
Low_tracks_out(TR_ind_1(FlagDel==1))=[];

end

