classdef Burst
   properties
      withinburst;
      no_of_openings;
      total_open_length;
      burst_length;
      burst_status=ScnRecording.STATUS_GOOD;
      burst_open_lengths=[];
      mean_amp;
    
       
   end
   
   
   
   
   methods
       function value = get.no_of_openings(obj)
            value = obj.no_of_openings;
       end
       
       
       
       
       function obj = Burst(wb,no_op,total_open, b_length,b_status, b_open_lens,m_amp)
            obj.withinburst=wb;
            obj.no_of_openings = no_op;
            obj.total_open_length = total_open;
            obj.burst_length = b_length;
            
            if (b_status>0)
                obj.burst_status =ScnRecording.STATUS_BAD
            end
            
            obj.burst_status = b_status;
            obj.burst_open_lengths =b_open_lens;
            obj.mean_amp =m_amp;
       end
   
   end
end