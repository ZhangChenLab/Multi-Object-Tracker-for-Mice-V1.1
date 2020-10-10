function [Low_tracks_out] = TrackletsMergeTiny_V1(Low_tracks_in,ObjN,ThreSeg,ThreSegRatio)
%  Ѱ��һ�α���Ϊtiny�Ĺ켣��ɾ��
%  ����������1������<=ThreSeg(*2)��2,3������ThreSeg*2��Χ��������ObjN�����Ϲ켣��ThreSeg*6�Ĺ켣
%  Low_tracks_in  |  input tracelets
%  ObjN  |  number of objects
%  ThreSeg  |  ������ֵ
%  ThreSegRatio(1,2)  |  �����Ƕ˵���ֵ��������ֵ��
%  -----------------------------------------
% ThreSegRatio=[1.2 2 6];

TR_SE=[Low_tracks_in(:).StartEnd]';
TR_SE=double(TR_SE);
Low_tracks_dura=TR_SE(:,2)-TR_SE(:,1);

TR_ind_1=find(Low_tracks_dura<=ThreSeg*ThreSegRatio(1));  % ׼��ɾ���Ĺ켣 | ����С��ThreSeg
TR_ind_2=Low_tracks_dura>=ThreSeg*ThreSegRatio(3);  % ���ȴ���ThreSeg*6�Ĺ켣
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

