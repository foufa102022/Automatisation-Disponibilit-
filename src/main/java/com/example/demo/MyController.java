package com.example.demo;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
@RestController
public class MyController {

    private final Counter myCounter;
    public MyController(MeterRegistry registry) {
        this.myCounter = Counter.builder("my_custom_counter")
                .description("A custom counter metric")
                .register(registry);
    }
    @GetMapping("/salutation")
    public String myEndpoint(Model model) {

// Increment the counter each time this endpoint is called
        myCounter.increment();
        return "<h1>Bonjour Master DevOps II<h1>";
    }


}
