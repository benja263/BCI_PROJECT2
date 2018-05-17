function [feet,hands,baseline] = separationLap(psd_file)
% Separate events 

for i=1:size(psd_file,1)

 
    baseline{i}=psd_file{i,4}(psd_file{i,5}==786,:,:);
    feet{i}=psd_file{i,4}(psd_file{i,5}==771,:,:);
    hands{i}=psd_file{i,4}(psd_file{i,5}==773,:,:);
 
    
    
    end
end

        
       

