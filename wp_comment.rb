# Jungtaek Lim(Heart)

# 워드프레스 댓글을 표현하는 클래스
# id : 고유 번호 // String
# author : 댓글 작성자 // String
# email : 메일 주소 // String
# url : 작성자가 남긴 URL // String
# ip : 작성한 곳의 IP // String
# write_date : 작성 날짜 // String
# content : 내용 // String
#
# 시각의 타입 : String(YYYY-MM-DD 24HR:MI:SS)
class WPComment
  attr_accessor :id, :author, :email, :url, :ip, :write_date, :content

  def initialize
    @id = nil
    @author = nil
    @email = nil
    @url = nil
    @ip = nil
    
    @write_date = nil
    @content = nil

  end
  
end
