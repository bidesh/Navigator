class StudentsController < ApplicationController
  before_filter :init
  
  def init
    @navigator = Student.new
  end
  
  
   def new
     @names  = @navigator.names
     @focus = @navigator.calc_center
   end
   
   def clicked
     @source = params[:source]
     @dest = params[:dest]
     @focus = @navigator.calc_center # this is where focus is set in the map
     
     
     ###########for source
     if @navigator.buildingHash.has_key?(String(@source))
       @id = @navigator.buildingHash[String(@source)] # this is an int, so change to sting
       @sourcePoints = @navigator.coorArray(@navigator.getEntrances(@id))
     else
       
       @id = @navigator.pointHash[String(@source)] 
       @coor = @navigator.getLatLonHash[@id]
       @sourcePoints = []
       @sourcePoints << [@coor[1], @coor[0]]
     end
     
     ###########for destination
     if @navigator.buildingHash.has_key?(String(@dest))
        @id = @navigator.buildingHash[String(@dest)] # this is an int, so change to sting
        @destPoints = @navigator.coorArray(@navigator.getEntrances(@id))
      else

        @id = @navigator.pointHash[String(@dest)] 
        @coor = @navigator.getLatLonHash[@id]
        @destPoints = []
        @destPoints << [@coor[1], @coor[0]]
      end
     
     
   end
   
   
   def overlay
      @names = @navigator.names
      @source = params[:source]
      @dest = params[:dest]
      @sourceID =  @navigator.findNode(@source.split(',').last, @source.split(',').first)
      @destID =  @navigator.findNode(@dest.split(',').last, @dest.split(',').first)
      
      @focus = @navigator.calc_center # this is where focus is set in the map
      @path = @navigator.makePathCompatible(@navigator.getShortestPath(@sourceID, @destID)) # array of array of floats
      
      #
      @dist = @navigator.graph.dist * 66930 # in meters
      @time = @dist/1000*13;        # in mins, average adult walking distance
      @a = @path[0]
      @b = @path[@path.size()-1]
      
   end
   
   def uploadXML
	uploaded_io = params[:upload]
	if (uploaded_io.blank?) == false
		if uploaded_io.content_type == "text/xml"  
			File.open(Rails.root.join('public', 'map.xml'), 'w:ASCII-8BIT') do |file|
				file.write(uploaded_io.read)
			end
			redirect_to :root
			
		else 
			redirect_to :root
		end
	
	else
		redirect_to :root
	end
  end
   
end
