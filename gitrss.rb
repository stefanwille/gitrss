require 'digest/md5'
  
def git_rss(repository_path, repository_title)
  git_history = `cd #{repository_path} && git log --max-count=20 --name-status`

  entries = git_history.split("\ncommit ")

  rss = """<?xml version='1.0' encoding='UTF-8' ?>
    <rss version='2.0'>

    <channel>
    <title>#{repository_title} Git Commits</title>
    <description>Git commits to your repository</description>
    <link>http://example.com/your_respository.xml</link>
    <lastBuildDate>#{Time.now}</lastBuildDate>
    <pubDate>#{Time.now}</pubDate>
  """

  entries.each do |entry|
    guid = entry.gsub(/^.*commit /ms, '')
    guid = guid.gsub(/\n.*$/ms, '')
    author_name = entry.gsub(/^.*Author: /ms, '').gsub(/ <.*$/ms, '')
    author_email = entry.gsub(/^.* </ms, '').gsub(/>.*$/ms, '')
    gravatar_hash = Digest::MD5.hexdigest(author_email)
    gravatar = "http://www.gravatar.com/avatar/#{gravatar_hash}"    
    date = entry.gsub(/^.*Date: +/ms, '').gsub(/\n.*$/ms, '')
    comments = entry.gsub(/^.*Date[^\n]*/ms, '')
    comment_lines = comments.split("\n")
    comment_lines = comment_lines.map {|line| line.strip}
    first_line_of_comments = comment_lines.find {|line| line =~ /\S/}
    first_line_of_comments ||= " "  
    
  
    rss += "
      <item>
        <title>#{first_line_of_comments} - #{author_name}</title>
        <description>#{author_name} made a commit on #{date}</description>
        <content><![CDATA[
          <h2>#{author_name}</h2>
          <p><a href='http://gravatar.com'><img src='#{gravatar}'> #{author_email}</a></p>
          <p>#{date}</p>
          <pre>#{comments}</pre>
        ]]></content>
        <link></link>
        <guid isPermaLink='false'>#{guid}</guid>
        <pubDate>#{date}</pubDate>
      </item>"
  end 

  rss += "
    </channel>
  </rss>"
end


repository_path = $*[0]
repository_title = $*[1]  
puts git_rss(repository_path, repository_title)
