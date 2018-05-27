function Classifier_plotFrequencyMap(data,type,user,date)
    % type is laplacian or CAR filtering
    % 1 for car, 2 for laplacian
    
    figure('color','w');
    if type == 1
        text = 'CAR';
    elseif type == 2
        text = 'Laplacian';
    else
        disp('Error Type can only be 1 for CAR or 2 for Laplacian')
        return
    end

    heat_map = calculateClassifierFisher(data,type)';
    imagesc(heat_map);
    ylabel('Channels');
    xlabel('Frequencies [Hz]');
    xticklabels(4:2:48);
    colorbar;
    set(gca,'FontSize',36);
    set(gca,'XTick', 1:1:23);
    set(gca,'YTick',2:2:16);
    string = [user, ' feature discriminability ', text, ' filtering ', date];
    %title(string);
   

    

end