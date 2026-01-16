package com.zigger.backend.service;

import com.zigger.backend.model.ChatMessage;
import com.zigger.backend.model.Profile;
import com.zigger.backend.repository.ChatMessageRepository;
import com.zigger.backend.repository.ProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class ChatService {

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private ProfileRepository profileRepository;

    public ChatMessage sendMessage(UUID senderId, UUID taskId, String content) {
        Profile sender = profileRepository.findById(senderId)
                .orElseThrow(() -> new RuntimeException("Sender not found"));
        
        ChatMessage message = new ChatMessage();
        message.setSender(sender);
        message.setTaskId(taskId);
        message.setContent(content);
        
        return chatMessageRepository.save(message);
    }

    public List<ChatMessage> getMessages(UUID taskId) {
        return chatMessageRepository.findByTaskIdOrderByCreatedAtAsc(taskId);
    }
}
