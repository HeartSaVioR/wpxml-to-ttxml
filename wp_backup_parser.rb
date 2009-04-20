# Jungtaek Lim(Heart)

require 'utils'
require 'wp_attachment'

# WPXML 내용을 파싱해서 카테고리, 포스트, 댓글, 트랙백 등의 정보로 보관하는 클래스
# @categories : 파싱된 카테고리 리스트 // Array of WPCategory
# @posts : 파싱된 포스트 리스트 // Array of WPPost
# @attachments : 파싱된 첨부파일 리스트 // Array of WPAttachment
class WPBackupParser
  
  attr_reader :categories, :posts, :attachments

  # xml_document : WPXML 의 내용 // Document
  def initialize(xml_document)
    @document = xml_document

    @categories = []
    @posts = []
    @attachments = []
  end

  # 실제로 파싱을 수행한다
  # 파싱 정보는 이미 생성자에서 받아져 있다
  def parse
    return if @document == nil

    parse_category
    parse_post
    
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
    XPath.each(@document, "//item") do |post|
      
      # post / page(일반 글 혹은 페이지)
	    if "attachment" != post.elements["wp:post_type"].text
				@posts.push( parse_post_detail(post) )
		  # 첨부파일
		  else
		  	@attachments.push( parse_attachment_detail(post) )
	  	end

    end
    
  end
  
  # 포스트 상세 내역 파싱
  # post_element : <item> 객체
  def parse_post_detail(post_element)
  	wp_post = WPPost.new
  	
		wp_post.status = post_element.elements["wp:status"].text
		
		password_text = post_element.elements["wp:post_password"].text
		wp_post.password = password_text if nil != password_text && "" != password_text
		
		wp_post.title = post_element.elements["title"].text
		wp_post.link = post_element.elements["link"].text
		wp_post.pub_date = post_element.elements["pubDate"].text
		wp_post.writer = post_element.elements["dc:creator"].text
		
		XPath.each(post_element, "category[@domain='category' & @nicename]") do |category_tag|
		  wp_post.add_category(category_tag.text)
		end
		
		XPath.each(post_element, "category[@domain='tag' & @nicename]") do |tag_tag|
		wp_post.add_tag(tag_tag.text)
		end
		
		wp_post.content = post_element.elements["content:encoded"].text
		wp_post.post_id = post_element.elements["wp:post_id"].text
		wp_post.post_date = post_element.elements["wp:post_date"].text
		
		comm_stats = post_element.elements["wp:comment_status"].text
		
		if comm_stats == "open"
		  wp_post.comment_status = true
		else
		  wp_post.comment_status = false
		end
		
		ping_stats = post_element.elements["wp:ping_status"].text
		
		if ping_stats == "open"
		  wp_post.ping_status = true
		else
		  wp_post.ping_status = false
		end
		
		parse_comment(post_element, wp_post)
		
		return wp_post
  end
  
  # 첨부파일 상세 내역 파싱
  # post_element : <item> 객체
  def parse_attachment_detail(post_element)
  	wp_attachment = WPAttachment.new
  	
  	url = post_element.elements["wp:attachment_url"].text
  	
  	file_name = url[url.rindex('/')+1..-1]
  	
  	wp_attachment.name = file_name.dclone
  	wp_attachment.attach_url = url
  	
  	file_name.upcase!
  	if file_name.index(/(\.JPG|\.GIF|\.PNG|\.PCX)/)
  		# 그림 파일이므로 미리 받아 그림 크기를 알아둔다
  		begin
	  		width, height = get_image_size_from_content( get_url_content(url) )
	  		
	  		wp_attachment.width = width
	  		wp_attachment.height = height
			rescue OpenURI::HTTPError => httperr
				# 일단은 아무것도 하지 않는다... 나중에 에러처리할 것임
			end
		end
  	
  	wp_attachment.post_date = post_element.elements["wp:post_date"].text
  	
  	return wp_attachment
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
