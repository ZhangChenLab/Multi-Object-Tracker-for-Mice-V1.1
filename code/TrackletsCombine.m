function Low_tracks = TrackletsCombine(tracks_back,tracks,ParaStruct)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
PredDel=ParaStruct.PredDel;  % 去掉断点轨迹 prediction box  
LenThre=ParaStruct.LenThre;  % 轨迹段长度阈值

Low_tracks= struct(...
    'frame', {}, ...      % 轨迹段出现的帧数
    'StartEnd', {}, ...   % 轨迹段出现的起始帧 与 结束帧
    'polybbox', {}, ...       % 对应的polybbox(All)
    'Ind', {}, ...        % 融合后处于第几小段 | 初始时都为1
    'Num', {}, ...        % 一共有N个小段
    'Fun', {});           % N个小段融合时对应的函数
Low_track_TR0=Low_tracks;
tracks_tar_T={'tracks_back','tracks'};

for ti=1:2
    tracks_tar=eval(tracks_tar_T{ti});
for ci=1:length(tracks_tar)
    Low_track_TR1=Low_track_TR0;
    TR_frame=tracks_tar(ci).frame;
    Low_track_TR1(1).frame=TR_frame(1:end+PredDel(ti));
    Low_track_TR1(1).StartEnd=[min(TR_frame(1:end+PredDel(ti))); max(TR_frame(1:end+PredDel(ti)))];
    Low_track_TR1(1).polybbox=tracks_tar(ci).polybboxAll(:,:,1:end+PredDel(ti));
    Low_track_TR1(1).Ind=ones(length(Low_track_TR1(1).frame),1,'uint32');
    Low_track_TR1(1).Num=1;
    Low_tracks(end+1)=Low_track_TR1;
end
end

TR1=[Low_tracks(:).StartEnd]';
Low_tracks_dura=TR1(:,2)-TR1(:,1);
Low_tracks(Low_tracks_dura<LenThre)=[];

TR1=[Low_tracks(:).StartEnd]';
[~,sb]=sort(TR1(:,1),'ascend');
Low_tracks=Low_tracks(sb);
end

