function [Low_tracks_out] = TrackletsMergeProminentDist_V1(Low_tracks_in,ThreSeg,ThreMDist,CharFun)
%  寻找与某一段轨迹最相关（Prominent）的轨迹 
%  长度条件:1）端点阈值ThreSeg(1)；2）长度阈值ThreSeg(2)
%  IoU条件：1）最相关与次相关IoU差值ThreM(1)；2）最相关IoU大于ThreM(2)
%  Low_tracks   tracklets
%  ThreSeg | gap overlap length | 逐步减弱条件 + + -
%  ThreMDist | Dist阈值 | 2nd/1st(ascend) 1st dist阈值

if length(Low_tracks_in)==1  % 只有一段轨迹，不做后续处理
    Low_tracks_out=Low_tracks_in;
    return
end

TR1=[Low_tracks_in(:).StartEnd]';
Low_tracks_dura=TR1(:,2)-TR1(:,1);

[~,TracksCostDist] = TrackletsMergeCostM_V1(Low_tracks_in,ThreSeg);

% %% cost matrix
TR_cost=TracksCostDist;
% TR_cost(TR_cost==inf)=1;
% TR_cost=TR_cost+TR_cost'-1;
[TR_cost_2,TR_cost_ind]=sort(TR_cost,'ascend');

TR2_0=TR_cost_2(2,:)./TR_cost_2(1,:);
TR2_0(isnan(TR2_0))=0;
TR2_1=TR2_0>=ThreMDist(1);
TR2_0(TR2_0==inf)=2.5;
TR2_2=TR_cost_2(1,:)<=ThreMDist(2)*(1+TR2_0);  % 动态阈值
TR2_3=TR_cost_2(2,:)>=ThreMDist(3);
TR3=TR2_1.*TR2_2.*TR2_3;
TR2_ind=find(TR3==1);

TR2_ind_1=TR_cost_ind(1,TR2_ind); % 
TR2_ind_value=TR_cost_2(1,TR2_ind);
TR2_ind_assign=[TR2_ind; TR2_ind_1];

% % ------
TR2_ind_assign=sort(TR2_ind_assign,'ascend');
[TR2_ind_assign_U,ia,~] = unique(TR2_ind_assign','rows');
TR2_ind_assign_U=TR2_ind_assign_U';
TR2_ind_value_U=TR2_ind_value(ia);
% % assign
CostM=sparse(TR2_ind_assign_U(1,:),TR2_ind_assign_U(2,:),TR2_ind_value_U,length(Low_tracks_in),length(Low_tracks_in));
CostM=full(CostM);
CostM=CostM/max(CostM,[],'all');
CostM(CostM==0)=inf;
CostM(isnan(CostM))=inf;
costOfNonAssignment = 0.7;   % low --> new track | high --> one track to many detection
unassignedTrackCost = 1;
unassignedDetectionCost=1;
[assignments, ~, ~] = ...
    assignDetectionsToTracks( CostM, unassignedTrackCost,unassignedDetectionCost); % Munkres' version of the Hungarian algorithm
assignments=unique(assignments,'rows');

% %% %     modifing assignment
for cj=1:size(assignments,1)  % 长度阈值条件
    if min(Low_tracks_dura(assignments(cj,:)))<=ThreSeg(3)
        assignments(cj,:)=0;
    end
end
assignments(assignments(:,1)==0,:)=[];
if ~isempty(assignments)
    for ci=1:size(assignments,1)  % 融合后变短不融合
        Ind_1=assignments(ci,1);
        Ind_2=assignments(ci,2);
        frame_1_ind=Low_tracks_in(Ind_1).StartEnd;
        frame_2_ind=Low_tracks_in(Ind_2).StartEnd;
        if frame_1_ind(2)>=frame_2_ind(2)
            assignments(ci,:)=0;
        end
    end
end
assignments(assignments(:,1)==0,:)=[];

% % combine tracks
Low_tracks_out = TrackletsMergeOperation_V1(Low_tracks_in,assignments);

end

