require 'rexml/document'
require 'erb'
include REXML

class Student < ActiveRecord::Base
      def initialize
          @names = []
          @pointHash = {}
          @buildingHash = {}
          @hash = {}
          @latLonHash = {}
          @xmlfile = File.new("./public/map.xml")
          @xmldoc = Document.new(@xmlfile)
          @gr = Graph.new

          @xmldoc.elements.each("osm/way/nd"){
              |f|
              id  = f.parent.attributes["id"]
              ref = f.attributes["ref"]
              if (not @hash.has_key?(id))
                  @hash[id] = [ref]
                  else
                  @hash[id]<< ref
              end
          }


          def calc_center()
              array = Array.new
              @xmldoc.elements.each("osm/bounds"){
                  |f|
                  minlat = f.attributes["minlat"]
                  minlon = f.attributes["minlon"]
                  maxlat = f.attributes["maxlat"]
                  maxlon = f.attributes["maxlon"]

                  centre_lat = (minlat.to_f + maxlat.to_f)/2
                  centre_lon = (minlon.to_f + maxlon.to_f)/2
                  array.push centre_lat
                  array.push centre_lon
              }
              return array

          end




          @xmldoc.elements.each("osm/node"){
              |e|
              @latLonHash[e.attributes["id"].to_i] = [e.attributes["lat"].to_f, e.attributes["lon"].to_f]
          }

          @hash.each { |k, v|

              v.each_with_index do |item, index|
                  if (index != v.length-1)
                      @gr.add_edge(v[index].to_i, v[index+1].to_i, distance(@latLonHash[v[index].to_i], @latLonHash[v[index+1].to_i]))
                  end
              end

          }

          @xmldoc.elements.each("osm/node/tag"){
              |e|
              if e.attributes["k"] == "name"
                  @pointHash[e.attributes["v"]] = e.parent.attributes["id"].to_i
                  @names << e.attributes["v"]
              end
          }

          @xmldoc.elements.each("osm/way/tag"){
              |e|
              if e.attributes["k"] == "name"
               @buildingHash[e.attributes["v"]] = e.parent.attributes["id"].to_i
              @names << e.attributes["v"]
              end
          }

      end


      def graph
          return @gr
      end

      def getNameList
          String("["+@names.map{|i|  %Q("#{i}")}.join(" , ")+"]")
      end


      def distance (a,b)
          return Math.hypot(b[0]-a[0],b[1]-a[1])
      end

      def getId(name) # this has to me modified later
          return @pointHash[name]
      end


      def names
          return @names
      end

      def pointHash
          return @pointHash
      end

      def buildingHash
          return @buildingHash
      end

      def hash
          return @hash
      end

      def getLatLonHash
          return @latLonHash
      end


      def getBuildingPoints(id)
          return @hash[id]
      end


      def getShortestPath(a, b)
          @gr.shortest_paths(a, b)
      end



      def makePathCompatible(listOfNodes)
          values = Array.new
          listOfNodes.each {
              |node|
              coor = @latLonHash[node]
              values << [coor[1], coor[0]]
          }
          return values
      end


      def coorArray(list)
          array = Array.new
          list.each {
              |node|
              array << Integer(node)
          }
          return makePathCompatible(array)
      end


      def getEntrances(id) # id is the id of a building, Integer
          list =  @hash[String(id)]
          entrance = []
          list.each {
              |node|
              @hash.each_pair do |k,v|
                  if v.include?(node) and k != String(id) and !entrance.include?(node)
                      entrance << node
                  end
              end

          }
          return entrance
      end

      def findNode(lat, long)
          @latLonHash.each_pair do |k,v|
              if v[0] == Float(lat) and v[1] == Float(long)
                  return k
              end
          end
          return -1
      end


      #**************************
      class Graph

          # Constructor

          def initialize
              @g = {}
              @dist = -1
              @nodes = Array.new
              @INFINITY = 1 << 64
              @path = Array.new
          end

          def dist
              return @dist
          end

          def path
              @path
          end


          def hash_map
              @g
          end


          def add_edge(s,t,w)

              if (not @g.has_key?(s))
                  @g[s] = {t=>w}
                  else
                  @g[s][t] = w
              end


              if (not @g.has_key?(t))
                  @g[t] = {s=>w}
                  else
                  @g[t][s] = w
              end


              if (not @nodes.include?(s))
                  @nodes << s
              end
              if (not @nodes.include?(t))
                  @nodes << t
              end
          end

          #end


          def dijkstra(s)
              @d = {}
              @prev = {}

              @nodes.each do |i|
                  @d[i] = @INFINITY
                  @prev[i] = -1
              end

              @d[s] = 0
              q = @nodes.compact
              while (q.size > 0)
                  u = nil;
                  q.each do |min|
                      if (not u) or (@d[min] and @d[min] < @d[u])
                          u = min
                      end
                  end
                  if (@d[u] == @INFINITY)
                      break
                  end
                  q = q - [u]
                  @g[u].keys.each do |v|
                      alt = @d[u] + @g[u][v]
                      if (alt < @d[v])
                          @d[v] = alt
                          @prev[v]  = u
                      end
                  end
              end
          end

          # To print the full shortest route to a node



          def print_path(dest)
              if @prev[dest] != -1
                  print_path @prev[dest]
              end
              @path << dest
          end

          # Gets all shortests paths using dijkstra

          def shortest_paths(s, dest)
              @source = s
              dijkstra s
              #puts "Source: #{@source}"
              #puts "\nTarget: #{dest}"
              #print_path dest

              if @d[dest] != @INFINITY
                  @dist = @d[dest]
                  else
                  puts "\nNO PATH"
              end

              print_path dest

          end
      end
      #**************************


  end





