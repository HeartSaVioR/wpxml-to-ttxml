# Jungtaek Lim(Heart)

# WPXML 내용을 파싱해서 카테고리, 포스트, 댓글, 트랙백 등의 정보로 보관하는 클래스
# @categories : 파싱된 카테고리 리스트 // Array of WPCategory
# @posts : 파싱된 포스트 리스트 // Array of WPPost
class WPBackupParser
  
  attr_reader :categories, :posts

  # xml_document : WPXML 의 내용 // Document
  def initialize(xml_document)
    @document = xml_document

    @categories = []
    @posts = []
  end

  # 실제로 파싱을 수행한다
  # 파싱 정보는 이미 생성자에서 받아져 있다
  def parse
    return if @document == nil

    parse_category
    parse_post
    
  end

  # 테스트용 : 카테고리 리스트를 출력
  def print_categories
    @categories.each do |cat_obj|
      if cat_obj.parent != nil
        puts cat_obj.name + " / " + cat_obj.parent
      else
        puts cat_obj.name + " / "
      end

    end
  end

  # 테스트용 : 포스트 리스트를 출력
  def print_posts
    puts "Post Count : " + @posts.length.to_s

    @posts.each do |post_obj|
      puts post_obj.title

      post_obj.categories.each do |cat_name, category|
        puts cat_name
      end

      puts "Comments : " + post_obj.comments.length.to_s

    end
  end

  private

  # 카테고리 부분 파싱
  def parse_category
    # Category Parsing & Store
    XPath.each(@document, "//wp:category") do |category|
      wp_category = WPCategory.new

      wp_category.name = category.elements["wp:cat_name"].text

      cat_parent = category.elements["wp:category_parent"].text

      if (cat_parent != nil && cat_parent != "")
        wp_category.parent = cat_parent
      else
        wp_category.parent = nil
      end

      @categories.push wp_category

    end
  end

    # 포스트 부분 파싱
  def parse_post
    # Post Parsing & Store
    XPath.each(@document, "//item") do |post|
      wp_post = WPPost.new

	  # 첨부 파일 가려냄
	  # 일단은 첨부파일은 적용대상에서 제외시키는것으로 처리
	  next if "attachment" == post.elements["wp:post_type"].text
	  
      wp_post.status = post.elements["wp:status"].text
      
      password_text = post.elements["wp:post_password"].text
      wp_post.password = password_text if nil != password_text && "" != password_text

      wp_post.title = post.elements["title"].text
      wp_post.link = post.elements["link"].text
      wp_post.pub_date = post.elements["pubDate"].text
      wp_post.writer = post.elements["dc:creator"].text

      XPath.each(post, "category[@domain='category' & @nicename]") do |category_tag|
        wp_post.add_category(category_tag.text)
      end

      XPath.each(post, "category[@domain='tag' & @nicename]") do |tag_tag|
        wp_post.add_tag(tag_tag.text)
      end

      wp_post.content = post.elements["content:encoded"].text
      wp_post.post_id = post.elements["wp:post_id"].text
      wp_post.post_date = post.elements["wp:post_date"].text

      comm_stats = post.elements["wp:comment_status"].text

      if comm_stats == "open"
        wp_post.comment_status = true
      else
        wp_post.comment_status = false
      end

      ping_stats = post.elements["wp:ping_status"].text

      if ping_stats == "open"
        wp_post.ping_status = true
      else
        wp_post.ping_status = false
      end

      parse_comment(post, wp_post)

      @posts.push(wp_post)

    end
  end

  # 댓글 부분 파싱
  # post : 포스트 부분의 태그 // Element
  # wp_post_obj : 댓글 저장할 포스트 객체 // WPPost
  def parse_comment(post, wp_post_obj)
    # comments Parsing & Store
      XPath.each(post, "wp:comment") do |comment|
        wp_comment = WPComment.new

        approved = comment.elements["wp:comment_approved"].text

        # 주의 : 수용된 댓글만 저장함
        next unless approved == "1"     # "1": accepted

        wp_comment.id = comment.elements["wp:comment_id"].text
        wp_comment.author = comment.elements["wp:comment_author"].text
        wp_comment.email = comment.elements["wp:comment_author_email"].text
        wp_comment.url = comment.elements["wp:comment_author_url"].text
        wp_comment.ip = comment.elements["wp:comment_author_IP"].text
        wp_comment.content = comment.elements["wp:comment_content"].text
        wp_comment.write_date = comment.elements["wp:comment_date"].text

        wp_post_obj.add_comment(wp_comment)
      end
  end

end
