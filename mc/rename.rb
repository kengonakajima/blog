`ls -1`.split("\n").each do |fn|
  renamed = fn.gsub("スクリーンショット","screenshot")
  renamed.gsub!(" ","_")
  # print renamed,"\n"
  system("mv \"#{fn}\" \"#{renamed}\" ")
end
  