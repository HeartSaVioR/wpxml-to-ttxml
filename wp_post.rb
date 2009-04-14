# Jungtaek Lim(Heart)

# ���������� ����Ʈ�� ǥ���ϴ� Ŭ����
# title : ���� // String
# link : ����Ʈ �ּ� // String
# pub_date : ���� �ð� // String
# writer : �ۼ��ڸ� // String
# tags : �±� ����Ʈ // Array of String
# categories : ī�װ� ����Ʈ // Array of String
# content : ���� // String
# post_id : ����Ʈ�� ID // String
# post_date : ��� �ð� // String
# comment_status : ��� ��� ���� // String(open/closed)
# ping_status : Ʈ���� & �ι� ��� ���� // String(open/closed)
# comments : ��� ����Ʈ // Array of WPComment
#
# �ð��� Ÿ�� : String(YYYY-MM-DD 24HR:MI:SS)
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

  # ��� �߰�
  # comment : ��� // WPComment
  def add_comment(comment)
    @comments.push comment

    @comments.sort! {|x, y| x.write_date <=> y.write_date }
  end

  # ī�װ� �߰�
  # category : ī�װ��� // String
  def add_category(category)
    @categories[category] = category
    
  end

  # �±� �߰�
  # tag : �±� // String
  def add_tag(tag)
    @tags[tag] = tag
    
  end

end
