# 태터 계열 댓글 클래스
# Jungtaek Lim(Heart)

# 태터 계열 댓글 클래스
# @email : 메일 주소 // String
# @name : 이름 // String
# @homepage : 홈페이지 URL // String
# @ip : 댓글 남긴 IP // String
# @content : 댓글 내용 // String
# @password : 댓글 패스워드 // String
# @secret : 비밀 댓글 여부 // true/false
# @write_date : 댓글 작성 시각 // String
#
# * 시각은 00:00:00 UTC on January 1, 1970 기준으로 지난 시간 - sec
class TTComment
  attr_accessor :email, :name, :homepage, :ip, :content, :password,
    :secret, :write_date
  
  def initialize
    @email = nil
    @name = nil
    @homepage = nil
    @ip = nil
    @content = nil
    @password = nil
    @secret = nil
    @write_date = nil
    
  end

end
