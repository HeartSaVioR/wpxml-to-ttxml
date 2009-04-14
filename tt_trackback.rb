# 태터 계열 트랙백 클래스
# Jungtaek Lim(Heart)

# 태터 계열 트랙백 클래스
# @url : 트랙백 주소 // String
# @sitename : 트랙백 보낸 사이트의 이름 // String
# @title : 트랙백 제목 // String
# @excerpt : 내용발췌 // String
# @ip : 트랙백 보낸 IP // String
# @receive_date : 트랙백 받은 날짜 // String
#
# * 시각은 00:00:00 UTC on January 1, 1970 기준으로 지난 시간 - sec
class TTTrackback
  attr_accessor :url, :sitename, :title, :excerpt, :ip, :receive_date

  def initialize
    @url = nil
    @sitename = nil
    @title = nil
    @excerpt = nil
    @ip = nil
    @receive_date = nil
    
  end
end
