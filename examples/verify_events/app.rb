class VerifyEventsApp
  def run
    puts "Press any key, click mouse, resize window, or paste text."
    puts "Press 'q' to exit."

    RatatuiRuby.run do
      loop do
        event = RatatuiRuby.poll_event
        next unless event

        RatatuiRuby.restore_terminal
        puts "Event Class: #{event.class}"
        puts "Inspect: #{event.inspect}"
        
        if event.key?
          puts "  Symbol Match (:q): #{event == :q}"
          puts "  String Match ('q'): #{event == 'q'}"
          puts "  Predicates: ctrl=#{event.ctrl?} alt=#{event.alt?} shift=#{event.shift?} text=#{event.text?}"
        end

        if event.mouse?
          puts "  Predicates: down=#{event.down?} up=#{event.up?} drag=#{event.drag?} scroll_up=#{event.scroll_up?}"
        end
        
        puts "-------------------"
        RatatuiRuby.init_terminal 

        if event == :q || event == :ctrl_c
          break
        end
      end
    end
  end
end

VerifyEventsApp.new.run if __FILE__ == $PROGRAM_NAME
