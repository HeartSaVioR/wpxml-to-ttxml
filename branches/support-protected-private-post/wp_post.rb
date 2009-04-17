# Jungtaek Lim(Heart)

# 워드프레스 포스트를 표현하는 클래스
# title : 제목 // String
# link : 포스트 주소 // String
# pub_date : 공개 시각 // String
# writer : 작성자명 // String
# tags : 태그 리스트 // Array of String
# categories : 카테고리 리스트 // Array of String
# content : 내용 // String
# post_id : 포스트의 ID // String
# post_date : 등록 시각 // String
# comment_status : 댓글 허용 여부 // String(open/closed)
# ping_status : 트랙백 & 핑백 허용 여부 // String(open/closed)
# comments : 댓글 리스트 // Array of WPComment
#
# 시각의 타입 : String(YYYY-MM-DD 24HR:MI:SS)
class WPPost
  attr_accessor :title, :link, :pub_date, :writer, :tags, :categories, :content, :post_id,
    :post_date, :comment_status, :ping_status, :comments
  
  def initialize
    @comments = []
    @categories = {}
    @tags = {}

    @title = nil
    @link = nil
    @pub_date = nil
    @writer = nil
    @content = nil
    @post_id = nil
    @post_date = nil
    @comment_status = true
    @ping_status = true
    
  end

  # 댓글 추가
  # comment : 댓글 // WPComment
  def add_comment(comment)
    @comments.push comment

    @comments.sort! {|x, y| x.write_date <=> y.write_date }
  end

  # 카테고리 추가
  # category : 카테고리명 // String
  def add_category(category)
    @categories[category] = category
    
  end

  # 태그 추가
  # tag : 태그 // String
  def add_tag(tag)
    @tags[tag] = tag
    
  end

end
