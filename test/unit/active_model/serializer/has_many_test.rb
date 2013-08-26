require 'test_helper'

module ActiveModel
  class Serializer
    class HasManyTest < ActiveModel::TestCase
      def setup
        @post = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
        @post_serializer = PostSerializer.new(@post)
        @association = PostSerializer._associations[0]
        @association.include = false
        @association.embed = :ids
      end

      def test_associations_definition
        assert_equal 1, PostSerializer._associations.length
        assert_kind_of Association::HasMany, @association
        assert_equal 'comments', @association.name
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_serialization_using_as_json
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash_and_key_from_options
        old_key = @association.key
        @association.key = 'key'
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'key' => @post.comments.map { |c| c.object_id }
        }, @post_serializer.serializable_hash)
      ensure
        @association.key = old_key
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash
        @association.embed = :objects
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comments' => [{ 'content' => 'C1' }, { 'content' => 'C2' }]
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_as_json
        @association.embed = :objects
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comments' => [{ 'content' => 'C1' }, { 'content' => 'C2' }]
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash_and_root_from_options
        @association.embed = :objects
        old_embedded_key = @association.embedded_key
        @association.embedded_key = 'root'
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'root' => [{ 'content' => 'C1' }, { 'content' => 'C2' }]
        }, @post_serializer.serializable_hash)
      ensure
        @association.embedded_key = old_embedded_key
      end

      def test_associations_embedding_ids_including_objects_serialization_using_serializable_hash
       @association.include = true
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }, 'comments' => [{ 'content' => 'C1' }, { 'content' => 'C2' }]
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_as_json
        @association.include = true
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }, 'comments' => [{ 'content' => 'C1' }, { 'content' => 'C2' }]
        }, @post_serializer.as_json)
      end

      def test_associations_using_a_given_serializer
        @old_serializer = @association.serializer_class
        @association.include = true
        @association.serializer_class = Class.new(ActiveModel::Serializer) do
          def content
            'fake'
          end

          attributes :content
        end

        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }, 'comments' => [{ 'content' => 'fake' }, { 'content' => 'fake' }]
        }, @post_serializer.as_json)
      ensure
        @association.serializer_class = @old_serializer
      end
    end
  end
end
