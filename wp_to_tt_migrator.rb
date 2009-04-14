# Jungtaek Lim(Heart)

require 'tt_category'
require 'tt_post'
require 'tt_comment'

# ���������� ������ ���Ͱ迭�� ��ȯ�ϰ� ��ȯ�� ������ �����ϴ� Ŭ����
# @wp_categories : ���������� ī�װ� ���� // Array of WPCategory
# @wp_posts : ���������� ����Ʈ ���� // Array of WPPost
# @tt_categories : ��ȯ�� ���Ͱ迭 ī�װ� ���� // Array of TTCategory
# @tt_posts : ��ȯ�� ���Ͱ迭 ����Ʈ ���� // Array of TTPost
# @tt_category_parent_map : ���� ī�װ� ����(�θ� ������ ����) // Map of {String, TTCategory}
class WPtoTTMigrator

  attr_reader :tt_categories, :tt_posts

  # wp_categories : ���������� ī�װ� ���� // Array of WPCategory
  # wp_posts : ���������� ����Ʈ ���� // Array of WPPost
  def initialize(wp_categories, wp_posts)
    @wp_categories = wp_categories
    @wp_posts = wp_posts

    @tt_categories = []
    @tt_posts = []

    @tt_category_parent_map = {}
  end

  # ��ȯ�� ����
  def migrate
    migrate_categories
    migrate_posts
    
  end

private

  # ī�װ� ��ȯ�� ����
  def migrate_categories
    parent_category_map = {}
    children_category_map = {}

    @wp_categories.each do |wp_cat|
      if wp_cat.parent != nil

        if children_category_map[wp_cat.parent] != nil
          # ���� : ī�װ� ���̴� 2�� ���ѵ�(���Ͱ迭 ����)
          puts "Category depth is 3 or upper!! Can't migrate to TTXML!!"
          exit(-1)
        end

        tt_category = parent_category_map[wp_cat.parent]

        if tt_category != nil
          tt_category.add_child(wp_cat.name)
        else
          tt_category = TTCategory.new
          tt_category.name = wp_cat.parent
          tt_category.add_child(wp_cat.name)

          parent_category_map[wp_cat.parent] = tt_category
        end
        
        children_category_map[wp_cat.name] = wp_cat
      else
        tt_category = parent_category_map[wp_cat.name]

        if tt_category == nil
          tt_category = TTCategory.new
          tt_category.name = wp_cat.name
          
          parent_category_map[wp_cat.name] = tt_category
        end
      end
    end

    parent_category_map.each_value do |category|
      @tt_categories.push(category)

      category.children.each do |child_category|
        @tt_category_parent_map[child_category] = category
      end

    end

  end

 # ����Ʈ ��ȯ�� ����
  def migrate_posts
    @wp_posts.each do |wp_post|

      if wp_post.categories.length != 1
        # ���� : ����Ʈ�� ī�װ��� �� �ϳ����� ��(���Ͱ迭 ����)
        puts "Post's category count is 2 or upper!! Can't migrate to TTXML!!"
        puts wp_post.title
        wp_post.categories.each do |category|
          puts category
        end
        exit(-1)
      end

      tt_post = TTPost.new
      tt_post.id = wp_post.post_id
      tt_post.visibility = "public"   # ���� ���ุ ������, WP�� ������ ������
      tt_post.title = wp_post.title
      tt_post.content = wp_post.content
      tt_post.location = "/"
      tt_post.password = nil          # �н����� ��ȣ���� �������� ����
      tt_post.accept_comment = wp_post.comment_status
      tt_post.accept_trackback = wp_post.ping_status

      pub_date = Time.parse(wp_post.pub_date)
      post_date = Time.parse(wp_post.post_date)

      tt_post.publish_date = pub_date.to_i
      tt_post.create_date = post_date.to_i
      tt_post.modify_date = pub_date.to_i

      post_category = nil

      wp_post.categories.each do |key, value|
        # must have one!!!
        post_category = key
        
        break
      end

      parent_category = @tt_category_parent_map[post_category]
      
      if parent_category != nil
        tt_post.category = parent_category.name + "/" + post_category
      else
        tt_post.category = post_category
      end

      wp_post.tags.each_value do |tag|
        tt_post.add_tag(tag)
      end

      wp_post.comments.each do |comment|
        tt_comment = TTComment.new

        tt_comment.name = comment.author
        tt_comment.ip = comment.ip
        tt_comment.homepage = comment.url
        tt_comment.password = nil
        tt_comment.secret = false
        tt_comment.content = comment.content

        write_date = Time.parse(comment.write_date)
        tt_comment.write_date = write_date.to_i
        
        tt_post.add_comment(tt_comment)
      end

      @tt_posts.push(tt_post)

    end

  end

end
