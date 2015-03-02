
require 'json'

# So far this utility will step through your "other bookmarks" nodes 
#   and remove empty folders and duplicates contained w/in each node

module ChromeTools::BookmarkUtils

  SUBDIR = 'children'
  TYPE = 'type'
  FOLDER = 'folder'
  NAME = 'name'
  URL = 'url'

  def self.cleanse_and_save(bookmarks,fname="./Bookmarks.out")
    write_file(self.cleanse(bookmarks),fname)
  end

  def self.read_file(fname="./Bookmarks")
    data = nil
    File.open(fname,'r'){|f|
      data = JSON(f.read)
    }
    data
  end

  def self.write_file(d,fname="./Bookmarks.out")
    File.write(fname,JSON.pretty_generate(d))
  end

  # kick off cleanse steps
  def self.cleanse(bookmarks)
    data = bookmarks['roots']['other']
    
    data = self.cleanse_step(data)

    bookmarks['roots']['other'][SUBDIR] = data[SUBDIR]
    bookmarks
  end

  # recursively do cleanse steps on nodes
  # : remove empty folders and on duplicate folders keep folder w/ most children
  def self.cleanse_step(root, level=0)
    map = {}
    list = []

    return root unless root[SUBDIR]

    root[SUBDIR].each{|node|

      node = self.cleanse_step(node,level+1) if node[TYPE] == FOLDER #&& level == 0

      puts "#{node[NAME]}: #{node[SUBDIR].count}" rescue nil #puts "#{node[NAME]}: #{node[url]}"

      val = map[ node[NAME] ]

      if val && node[TYPE] == FOLDER then

        if val[SUBDIR].count < node[SUBDIR].count && !node[SUBDIR].empty? then
          map[ node[NAME] ] = node
        elsif node[SUBDIR].empty?
          puts "#{node[NAME]} is empty..."
        end

      elsif node[TYPE] != FOLDER || !node[SUBDIR].empty?
        map[ node[NAME] ] = node
      end

    }

    list = map.values
    root[SUBDIR] = list
    root
  end

end
