# 태터 계열 포스트 클래스
# Jungtaek Lim(Heart)

# 태터 계열 포스트 클래스
# @id : 메일 주소 // String
# @visibility : 가시성(발행, 공개, 보호, 비공개) // String
# @title : 제목 // String
# @content : 내용 // String
# @location : 지역 // String
# @password : 포스트의 패스워드(보호글) // String
# @accept_comment : 댓글 허용 여부 // true/false
# @accept_trackback : 트랙백 허용 여부 // true/false
# @publish_date : 공개한 시각 // String
# @create_date : 작성 시각 // String
# @modify_date : 마지막으로 수정한 시각 // String
# @category : 포스트가 속한 카테고리 // TTCategory
# @tags : 포스트에 속한 태그들 // Array of String
# @comments : 포스트에 속한 댓글들 // Array of TTComment
# @trackbacks : 포스트에 속한 트랙백들 // Array of TTTrackback
#
# * 시각은 00:00:00 UTC on January 1, 1970 기준으로 지난 시간 - sec
class TTPost
  attr_accessor :id, :visibility, :title, :content, :location, :password,
    :accept_comment, :accept_trackback, :publish_date, :create_date,
    :modify_date, :category, :tags, :comments, :trackbacks

  def initialize
    @comments = []
    @trackbacks = []
    @tags = []

  end

  # 댓글 추가
  # comment : 댓글 // TTComment
  def add_comment(comment)
    @comments.push(comment)

    @comments.sort! {|x, y| x.write_date <=> y.write_date }
  end

  # 트랙백 추가
  # trackback : 트랙백 // TTTrackback
  def add_trackback(trackback)
    @trackbacks.push(trackback)
  end

  # 태그 추가
  # tag : 태그 // String
  def add_tag(tag)
    @tags.push(tag)
  end

end
