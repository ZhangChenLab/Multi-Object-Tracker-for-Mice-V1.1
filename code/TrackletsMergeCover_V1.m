function [Low_tracks_out] = TrackletsMergeCover_V1(Low_tracks_in,ObjN,ThreSeg,ThreCover)
%  寻找与某一段已经被覆盖的轨迹 
%  满足条件：1）存在ObjN条以上轨迹，覆盖该轨迹；2）覆盖端点阈值ThreSeg；3）覆盖比例阈值ThreSeg
%  Low_tracks_in  |  input tracelets
%  ObjN  |  number of objects
%  ThreSeg  |  覆盖端点阈值
%  ThreCover  |  覆盖比例阈值
%  -----------------------------------------
TR1=[Low_tracks_in(:).StartEnd]';
TR1=double(TR1);
% Low_tracks_dura=TR1(:,2)-TR1(:,1);

CoverM=ones(length(Low_tracks_in));
for ci=1:length(Low_tracks_in)-1  % 
    for cj=ci+1:length(Low_tracks_in)-1 % 检测是否被覆盖
        if TR1(ci,1)+ThreSeg(1)<=TR1(cj,1) && TR1(ci,2)>=TR1(cj,2)+ThreSeg(1)
            CoverM(ci,cj)=(TR1(cj,2)-TR1(cj,1))/(TR1(ci,2)-TR1(ci,1));
        end
    end
end
CoverM_sort=sort(CoverM,'ascend');
CoverM_sort_obj=CoverM_sort(ObjN,:);

Low_tracks_out=Low_tracks_in;
Low_tracks_out( CoverM_sort_obj<=ThreCover )=[];

end

