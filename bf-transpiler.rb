class BFTranspiler
  STACK_LAST_INDEX = 3
  STACK = 0..STACK_LAST_INDEX
  ACC = STACK_LAST_INDEX + 1
  MEM = Hash.new { |_, i| ACC + i }

  StackOverflow = Class.new ::StandardError
  StackUnderflow = Class.new ::StandardError
  EmptyStack = Class.new ::StandardError

  attr_reader :caret

  def initialize
    @stack_top = STACK.begin - 1
    @indent = 0
    @caret = 0
    @output = ''
  end

  def go_to(pos)
    if @caret < pos
      output '>' * (pos - @caret)
    else
      output '<' * (@caret - pos)
    end
    @caret = pos
  end

  def go_to_acc
    go_to ACC
  end

  def acc=(value)
    go_to_acc and set value
  end

  def clear
    output '[-]'
  end

  def set(value)
    clear
    inc value
  end

  def output(bf_code)
    @output << ' ' * @indent << bf_code << "\n" if bf_code.length > 0
  end

  def comment(text)
    output "# #{ text }"
  end

  def dec(n = 1)
    output '-' * n
  end

  def inc(n = 1)
    output '+' * n
  end

  def repeat(n, &block)
    carret_pos = caret
    go_to inc_stack and set n
    count_down stack do
      go_to carret_pos
      yield
    end
    dec_stack
    go_to carret_pos
  end

  def count_down(field = ACC, &block)
    go_to field
    output '['
    @indent = @indent + 2
    dec
    yield
    go_to field
    @indent = @indent - 2
    output ']'
  end

  def stack
    raise EmptyStack if @stack_top == STACK.begin - 1
    @stack_top
  end

  def inc_stack
    @stack_top += 1
    raise StackOverflow if @stack_top > STACK.end
    @stack_top
  end

  def dec_stack
    @stack_top -= 1
    raise StackUnderflow if @stack_top < STACK.begin - 1
    @stack_top
  end

  def copy(from, to)
    go_to to and clear
    count_down from do
      go_to_acc and inc
      go_to to and inc
    end

    count_down do
      go_to from and inc
    end
  end

  def add(sum, b)
    count_down b do
      go_to sum and inc
    end
  end

  def subtract(a, b)
    count_down b do
      go_to a and dec
    end
  end

  def export_debug
    @output
  end

  def export
    export_debug.gsub /[^\[\]><+\-.,]/, ''
  end

  def compile(code)
    eval code
  end

  def input
    output ','
  end

  def show
    output '.'
  end
end

bft = BFTranspiler.new

code = <<CODE

go_to MEM[0] and input
go_to MEM[1] and input
add MEM[0], MEM[1]
go_to MEM[0] and show

CODE

bft.compile code
puts bft.export
