
require 'json'

# So far this utility will step through your "other bookmarks" nodes 
#   and remove empty folders and duplicates contained w/in each node

module ChromeTools::BookmarkUtils

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
    sub='children'
    type='type'
    folder='folder'
    
    data = self.cleanse_step(data)

    bookmarks['roots']['other'][sub] = data[sub]
    bookmarks
  end

  # recursively do cleanse steps on nodes
  # : remove empty folders and on duplicate folders keep folder w/ most children
  def self.cleanse_step(root, level=0)
    sub='children'
    type='type'
    folder='folder'
    url = 'url'
    
    map = {}
    list = []

    return root unless root[sub]

    root[sub].each{|node|

      node = self.cleanse_step(node,level+1) if node[type] == folder #&& level == 0

      puts "#{node['name']}: #{node[sub].count}" rescue nil #puts "#{node['name']}: #{node[url]}"

      val = map[ node['name'] ]

      if val && node[type] == folder then

        if val[sub].count < node[sub].count && !node[sub].empty? then
          map[ node['name'] ] = node
        elsif node[sub].empty?
          puts "#{node['name']} is empty..."
        end

      elsif node[type] != folder || !node[sub].empty?
        map[ node['name'] ] = node
      end

    }

    list = map.values
    root[sub] = list
    root
  end

end
