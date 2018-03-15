require_relative "normalizer"
module Vool
  class IfStatement < Statement
    include Normalizer

    attr_reader :condition , :if_true , :if_false

    def initialize( cond , if_true , if_false = nil)
      @condition = cond
      @if_true = if_true
      @if_false = if_false
      simplify_condition
    end

    def normalize
      cond , rest = *normalize_name(@condition)
      fals = @if_false ? @if_false.normalize : nil
      me = IfStatement.new(cond , @if_true.normalize, fals)
      return me unless rest
      rest << me
    end

    def to_mom( method )
      if_true =   @if_true.to_mom( method )
      if_false =  @if_false ? @if_false.to_mom( method ) : nil
      condition , hoisted  = hoist_condition( method )
      cond = Mom::TruthCheck.new(condition.to_mom(method))
      check = Mom::IfStatement.new(  cond , if_true , if_false )
      check.hoisted = hoisted.to_mom(method) if hoisted
      check
    end

    def flatten(options = {})
      true_label = Label.new( "true_label_#{object_id}")
      false_label = Label.new( "false_label_#{object_id}")
      merge_label = Label.new( "merge_label_#{object_id}")
      first = condition.flatten( true_label: true_label , false_label: false_label)
      if hoisted
        head = hoisted.flatten
        head.append first
      else
        head = first
      end
      head.append true_label
      head.append if_true.flatten( merge_label: merge_label)
      if( if_false)
        head.append false_label
        head.append if_false.flatten( merge_label: merge_label)
      end
      head.append merge_label
      head
    end

    def collect(arr)
      @if_true.collect(arr)
      @if_false.collect(arr) if @if_false
      super
    end

    def simplify_condition
      return unless @condition.is_a?(ScopeStatement)
      @condition = @condition.first if @condition.single?
    end

    def has_false?
      @if_false != nil
    end

    def has_true?
      @if_true != nil
    end

  end
end
