package com.zigger.backend.service;

import com.zigger.backend.model.Notification;
import com.zigger.backend.model.Profile;
import com.zigger.backend.repository.NotificationRepository;
import com.zigger.backend.repository.ProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private ProfileRepository profileRepository;

    public void sendNotification(UUID recipientId, String title, String message) {
        Profile recipient = profileRepository.findById(recipientId).orElse(null);
        if (recipient == null) return;

        Notification notification = new Notification();
        notification.setRecipient(recipient);
        notification.setTitle(title);
        notification.setMessage(message);
        notificationRepository.save(notification);

        // TODO: Integrate Firebase/OneSignal here for Push Notification
    }

    public List<Notification> getMyNotifications(UUID userId) {
        return notificationRepository.findByRecipient_IdOrderByCreatedAtDesc(userId);
    }
}
