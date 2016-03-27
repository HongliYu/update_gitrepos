require "update_gitrepos/version"

# Utils
class Array
  def prog_each(&block)
    bar_length = (`tput cols` || 80).to_i - 30
    time_now = Time.now
    total = self.count
    last_flush = 0
    flush_time = 1
    self.each_with_index{|element, x|
      cur = (x + 1) * 100 / total
      time_left = (((Time.now - time_now) * (100 - cur)).to_f / cur).ceil
      if (Time.now - last_flush).to_i >= flush_time or time_left < 1
        time_left_graceful = Time.at(time_left).utc.strftime("%H:%M:%S")
        if time_left > 86400
          time_left_graceful = res.split(":")
          time_left_graceful[0] = (time_left_graceful[0].to_i + days * 24).to_s
          time_left_graceful = time_left_graceful.join(":")
        end
        print "\r"
        cur_len = (bar_length * (x + 1)) / total
        print "[" << (["#"] * cur_len).join << (["-"] * (bar_length - cur_len)).join << "] #{cur}% [#{time_left_graceful} left]"
        last_flush = Time.now
      end
      block.call element if block
    }
    puts "\n"
    "Done."
  end
end

# TODO:文件目录校验 .git，遍历目录下所有的.git库全部更新
def traverse(filePath)
  gitReposArray = Array.new
  if File.directory?(filePath)
    Dir.foreach(filePath) do |fileName|
      if File.directory?(filePath + "/" + fileName) and fileName != "." and fileName != ".."
        gitReposArray << (filePath + "/" + fileName)
      end
    end
  else
    puts "Files:" + filePath
  end
  return gitReposArray
end

def updateRepos(gitReposArray)
  gitReposArray.prog_each { 
    |repoPath|
    system("echo \n" )
    system("echo Begin update git repo：#{repoPath} \n cd #{repoPath} \n git pull")
  }
end

# Main
module UpdateGitrepos
  def self.run(filePath)
    puts "running..."
    if filePath.nil? || filePath.empty?
      puts "error: need git repos directory path"
    else
      if File.directory?(filePath)
        gitReposArray = traverse(filePath)
        updateRepos(gitReposArray)
      else
        puts "error: not a directory"
      end
    end
  end
end
