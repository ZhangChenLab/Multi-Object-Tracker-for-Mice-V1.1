function [Low_tracks_post] = TrackletsMergeOperation_V1(Low_tracks_pre,assignments)
%UNTITLED6 进行轨迹融合
%   Low_tracks_pre  待融合轨迹段
%   assignments     融合轨迹段索引
%   Low_tracks_post 融合后轨迹段

Low_tracks_post = Low_tracks_pre;

if ~isempty(assignments)
    [~,sb]=sort(assignments(:,2),'descend');  % 段从大到小连接
    assignments=assignments(sb,:);
    for ci=1:size(assignments,1)
        Ind_1=assignments(ci,1);
        Ind_2=assignments(ci,2);
        frame_1_ind=Low_tracks_pre(Ind_1).frame;
        frame_2_ind=Low_tracks_pre(Ind_2).frame;
        if frame_1_ind(end)>=frame_2_ind(1)  % frame_2(第2段)起始小于但不被包含于第一段，以第二段为标准
            TR1=find(frame_1_ind==frame_2_ind(1));
            Low_tracks_pre(Ind_1).frame=[Low_tracks_pre(Ind_1).frame(1:TR1-1); Low_tracks_pre(Ind_2).frame];
            Low_tracks_pre(Ind_1).polybbox=cat(3,Low_tracks_pre(Ind_1).polybbox(:,:,1:TR1-1), Low_tracks_pre(Ind_2).polybbox);
%             Low_tracks_pre(Ind_1).Ind=[Low_tracks_pre(Ind_1).Ind(1:TR1-1,:); ...
%                          Low_tracks_pre(Ind_1).Ind(end)+Low_tracks_pre(Ind_2).Ind];
%             Low_tracks_pre(Ind_1).Fun{end+1,2}=Low_tracks_pre(Ind_1).frame(TR1-1);  % merge 函数作用位置
        elseif frame_1_ind(end)+1==frame_2_ind(1)
            Low_tracks_pre(Ind_1).frame=[Low_tracks_pre(Ind_1).frame; Low_tracks_pre(Ind_2).frame];
            Low_tracks_pre(Ind_1).polybbox=cat(3,Low_tracks_pre(Ind_1).polybbox, Low_tracks_pre(Ind_2).polybbox);
%             Low_tracks_pre(Ind_1).Ind=[Low_tracks_pre(Ind_1).Ind; ...
%                          Low_tracks_pre(Ind_1).Ind(end)+Low_tracks_pre(Ind_2).Ind];
%             Low_tracks_pre(Ind_1).Fun{end+1,2}=Low_tracks_pre(Ind_1).frame(end);   % merge 函数作用位置
        else
            TR_N=frame_2_ind(1)-frame_1_ind(end);
            polybbox_1=double(Low_tracks_pre(Ind_1).polybbox(:,:,end));
            polybbox_2=double(Low_tracks_pre(Ind_2).polybbox(:,:,1));
            polybbox_LS=zeros(4,2,TR_N+1);
            for pi=1:4
                for pj=1:2
                    polybbox_LS(pi,pj,:)=linspace(polybbox_1(pi,pj),polybbox_2(pi,pj),TR_N+1);
                end
            end
            polybbox_LS(:,:,[1 end])=[];
            Low_tracks_pre(Ind_1).frame=[Low_tracks_pre(Ind_1).frame;frame_1_ind(end)+(1:TR_N-1)'; Low_tracks_pre(Ind_2).frame];
            Low_tracks_pre(Ind_1).polybbox=cat(3,Low_tracks_pre(Ind_1).polybbox,uint32(polybbox_LS), Low_tracks_pre(Ind_2).polybbox);
%             Low_tracks_pre(Ind_1).Ind=[Low_tracks_pre(Ind_1).Ind; ...
%                          (Low_tracks_pre(Ind_1).Ind(end)+1)*ones(size(polybbox_LS,1),1,'uint32'); ...
%                          Low_tracks_pre(Ind_1).Ind(end)+Low_tracks_pre(Ind_2).Ind];
%             Low_tracks_pre(Ind_1).Fun{end+1,2}=Low_tracks_pre(Ind_1).frame(end);   % merge 函数作用位置
        end
        Low_tracks_pre(Ind_1).StartEnd=[frame_1_ind(1); frame_2_ind(end)];
%         Low_tracks_pre(Ind_1).Num=Low_tracks_pre(Ind_1).Num+Low_tracks_pre(Ind_2).Num;
%         Low_tracks_pre(Ind_1).Fun{end,1}=CharFun;
%         if length(Low_tracks_pre(Ind_1).Ind)~=length(Low_tracks_pre(Ind_1).frame)
%             disp('err')
%         end
%         if ~isempty(Low_tracks_pre(Ind_2).Fun)
%             Low_tracks_pre(Ind_1).Fun(end+1:end+size(Low_tracks_pre(Ind_2).Fun,1),:)=Low_tracks_pre(Ind_2).Fun;
%         end
    end
    
    Low_tracks_post=Low_tracks_pre;
    Low_tracks_post( assignments(:,2) )=[];
end

end

