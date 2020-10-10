function [Output] = TrackletsPlot_V2(Low_tracks_in,VideoStruct,FrameInd,Type)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
TR_Dura=[Low_tracks_in(:).StartEnd]';
Output=[];
% Count_TR=zeros(1,max(TR_Dura(:)));

% frame || tracelets
if ~isempty(FrameInd)
    TR_frame=FrameInd;
    FrameInd_trackFlag=[];
    for ci=1:length(Low_tracks_in)
        if ~(TR_Dura(ci,2)<FrameInd(1) || TR_Dura(ci,1)>FrameInd(end))
            FrameInd_trackFlag=[FrameInd_trackFlag; ci];
        end
    end
    Low_tracks_in=Low_tracks_in(FrameInd_trackFlag);
    TR_Dura=[Low_tracks_in(:).StartEnd]';
    % 
    for ci=1:length(Low_tracks_in)
        if TR_Dura(ci,2)>FrameInd(end)
            TR_ind=find(Low_tracks_in(ci).frame==FrameInd(end));
            Low_tracks_in(ci).frame(TR_ind+1:end)=[];
            Low_tracks_in(ci).polybbox(:,:,TR_ind+1:end)=[];
            Low_tracks_in(ci).StartEnd(2)=FrameInd(end);
        end
        if TR_Dura(ci,1)<FrameInd(1)
            TR_ind=find(Low_tracks_in(ci).frame==FrameInd(1));
            Low_tracks_in(ci).frame(1:TR_ind-1)=[];
            Low_tracks_in(ci).polybbox(:,:,1:TR_ind-1)=[];
            Low_tracks_in(ci).StartEnd(1)=FrameInd(1);
        end
    end
    TR_Dura=[Low_tracks_in(:).StartEnd]';
else
    TR_frame=min(TR_Dura(:)):max(TR_Dura(:));
end
FrameInd=TR_frame;
% % % -------------------------------- plot ---------------------------------------
% for ci=1:length(Low_tracks_in)
%     Count_TR(TR_Dura(ci,1):TR_Dura(ci,2))=Count_TR(TR_Dura(ci,1):TR_Dura(ci,2))+1;
% end
% Output.Count_TR=Count_TR;

switch Type
    case 'Lines'   % 只显示分段追踪结果 | 线段展示 ------------------------------
        figure;
        hold on
        for ci=1:length(Low_tracks_in)
            plot(TR_Dura(ci,:),[ci ci],'k-')
        end
    case 'Video'     % 追踪结果 + images  parula jet hsv ------------------------
        % 读取video文件
        Color_ind=hsv(length(Low_tracks_in));
        VideoObj=VideoStruct.Obj;
        if isfield(VideoStruct,'ROIBbox')
            roiBbox=round(VideoStruct.ROIBbox);
        end
        ImRatio=0.4;
        
        figure(10)
        for ci=TR_frame   % 读帧
            figure(10); hold off;
            VideoObj.CurrentTime=(double(ci)-1)/VideoObj.Framerate; % video 索引是从0开始的
            frame = readFrame(VideoObj);     % 读取当前帧
            if isfield(VideoStruct,'tform') && isfield(VideoStruct,'outputView') 
                frame_0=imwarp(frame,VideoStruct.tform,'OutputView',VideoStruct.outputView);
            else
                frame_0=frame;
            end
            if isfield(VideoStruct,'ROIBbox')
                frame_0=frame_0(roiBbox(2):roiBbox(2)+roiBbox(4),roiBbox(1):roiBbox(1)+roiBbox(3),:);
            end
            frame_0=imresize(frame_0,ImRatio);
            
            cen_T=[];
            for cj=1:length(Low_tracks_in)  % tracklets
                if TR_Dura(cj,1)<=ci && TR_Dura(cj,2)>=ci
                    polybbox=Low_tracks_in(cj).polybbox(:,:,ci-TR_Dura(cj,1)+1);
                    polybbox=double(polybbox);
                    cen=mean(polybbox,1);
                    cen=permute(cen,[3 2 1]);
                    cen=cen*ImRatio;
                    if isfield(VideoStruct,'ROIBbox')
                        cen=cen-roiBbox(1:2)*ImRatio;
                    end
                    cen_T=[cen_T; cen 10 cj];
                end
            end
            frame_1=insertShape(frame_0,'FilledCircle',cen_T(:,1:3),'Color',Color_ind(cen_T(:,4),:)*255,'Opacity',0.6);
            frame_2=insertText(frame_1,[cen_T(:,1) cen_T(:,2)],cen_T(:,4),'TextColor','w',...
                'AnchorPoint','Center','BoxOpacity',0,'FontSize',18);
            
            imshow(frame_2)
            xlabel([num2str(ci) ' / [' num2str(TR_frame(1)) ' - ' num2str(TR_frame(end)) ']'])
        end
    case 'VideoTracking'     % 追踪结果 + images  parula jet hsv ------------------------
        % 读取video文件
        Color_ind=hsv(length(Low_tracks_in));
        VideoObj=VideoStruct.Obj;
        if isfield(VideoStruct,'ROIBbox')
            roiBbox=round(VideoStruct.ROIBbox);
        end
        ImRatio=0.4;
        
        VideoTrackingName=[VideoObj.Name(1:end-4) '_Tracking_' num2str(TR_frame(1),'%06d') '.avi'];   % 保存追踪图像
        VideoTrackingObj=fullfile(pwd,VideoTrackingName);
        VideoTrackingObj = VideoWriter(VideoTrackingObj);
        VideoTrackingObj.FrameRate = 24;  % Default 30
        % VideoTrackingObj.Quality = 50;    % Default 75
        open(VideoTrackingObj);
        
        for ci=TR_frame   % 读帧
            
            VideoObj.CurrentTime=(double(ci)-1)/VideoObj.Framerate; % video 索引是从0开始的
            frame = readFrame(VideoObj);     % 读取当前帧
            if isfield(VideoStruct,'tform') && isfield(VideoStruct,'outputView') 
                frame_0=imwarp(frame,VideoStruct.tform,'OutputView',VideoStruct.outputView);
            else
                frame_0=frame;
            end
            if isfield(VideoStruct,'ROIBbox')
                frame_0=frame_0(roiBbox(2):roiBbox(2)+roiBbox(4),roiBbox(1):roiBbox(1)+roiBbox(3),:);
            end
            frame_0=imresize(frame_0,ImRatio);
            
                        
            cen_T=[];
            for cj=1:length(Low_tracks_in)  % tracklets
                if TR_Dura(cj,1)<=ci && TR_Dura(cj,2)>=ci
                    polybbox=Low_tracks_in(cj).polybbox(:,:,ci-TR_Dura(cj,1)+1);
                    polybbox=double(polybbox);
                    cen=mean(polybbox,1);
                    cen=permute(cen,[3 2 1]);
                    cen=cen*ImRatio;
                    if isfield(VideoStruct,'ROIBbox')
                        cen=cen-roiBbox(1:2)*ImRatio;
                    end
                    cen_T=[cen_T; cen 10 cj];
                end
            end
            frame_1=insertShape(frame_0,'FilledCircle',cen_T(:,1:3),'Color',Color_ind(cen_T(:,4),:)*255,'Opacity',0.6);
            frame_2=insertText(frame_1,[cen_T(:,1) cen_T(:,2)],cen_T(:,4),'TextColor','w',...
                'AnchorPoint','Center','BoxOpacity',0,'FontSize',18);
            
            % figure(10); % hold off;
            % imshow(frame_2)
            % xlabel([num2str(ci) ' / [' num2str(TR_frame(1)) ' - ' num2str(TR_frame(end)) ']'])
            
            % f=getframe;     pic=f.cdata;  % 获得当前显示的图像
            writeVideo(VideoTrackingObj,frame_2);
        end  
        close(VideoTrackingObj)
    case 'Trace2DTime'    % show overlay traces  -------------------------------
        windowLabel=5;
        figure(10); hold on;
        axis equal; set(gca,'YDir','reverse')
        for ci=1:length(Low_tracks_in)
            TR_polybbox=Low_tracks_in(ci).polybbox;
            TR_polybbox=double(TR_polybbox);
            TR_cen=mean(TR_polybbox,1);
            TR_cen=permute(TR_cen,[3 2 1]);
            TR_cen_smooth=TR_cen;
            for cj=ceil(windowLabel/2)  :size(TR_cen,1)-floor(windowLabel/2)
                TR_ind_window=cj-floor(windowLabel/2):cj+floor(windowLabel/2);
                TR1=TR_cen(TR_ind_window,:);
                TR_cen_smooth(cj,:)=mean(TR1);
            end
            x=[TR_cen_smooth(:,1); nan];
            y=[TR_cen_smooth(:,2); nan];
            c=[max([FrameInd(1) TR_Dura(ci,1)]):min([FrameInd(end) TR_Dura(ci,2)]) nan];
            patch(x,y,c,'edgecolor','flat','facecolor','none','LineWidth',2)
        end
        caxis(FrameInd([1 end]))
        colorbar
    case 'Trace2DTrace'    % 3D traces | x*y*t with color  -------------------------------
        ColorT=parula(length(Low_tracks_in));
        windowLabel=5;
        figure; hold on; 
        axis equal; set(gca,'YDir','reverse')
        for ci=1:length(Low_tracks_in)
            TR_polybbox=Low_tracks_in(ci).polybbox;
            TR_polybbox=double(TR_polybbox);
            TR_cen=mean(TR_polybbox,1);
            TR_cen=permute(TR_cen,[3 2 1]);
            TR_cen_smooth=TR_cen;
            for cj=ceil(windowLabel/2)  :size(TR_cen,1)-floor(windowLabel/2)
                TR_ind_window=cj-floor(windowLabel/2):cj+floor(windowLabel/2);
                TR1=TR_cen(TR_ind_window,:);
                TR_cen_smooth(cj,:)=mean(TR1);
            end
            x=TR_cen_smooth(:,1);
            y=TR_cen_smooth(:,2);
            plot(x,y,'Color',ColorT(ci,:),'LineWidth',2)
        end
        
    case 'NoPlot'
        
    otherwise
        disp('Error in figure types')
        return;
end

end

