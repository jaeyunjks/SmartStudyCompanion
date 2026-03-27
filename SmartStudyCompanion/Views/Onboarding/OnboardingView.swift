import SwiftUI

/// Enhanced Onboarding with iOS 26 real glassmorphism and cute illustrations
struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    @State private var hoveredCard: Int? = nil
    
    var body: some View {
        ZStack {
            // Multi-layer gradient background with depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.90, blue: 0.98),    // Light periwinkle
                    Color(red: 0.75, green: 0.85, blue: 0.95),    // Soft blue-purple
                    Color(red: 0.80, green: 0.88, blue: 0.96)     // Misty blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background orbs for depth
            VStack(spacing: 0) {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.90, green: 0.95, blue: 1.0).opacity(0.4),
                                Color(red: 0.85, green: 0.92, blue: 0.98).opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: -150, y: -150)
                    .blur(radius: 80)
                
                Spacer()
                
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.88, green: 0.93, blue: 0.99).opacity(0.3),
                                Color(red: 0.82, green: 0.90, blue: 0.97).opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 350, height: 350)
                    .offset(x: 120, y: 80)
                    .blur(radius: 70)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if currentPage > 0 {
                                currentPage -= 1
                            }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(Color(red: 0.35, green: 0.60, blue: 0.95))
                        .opacity(currentPage == 0 ? 0.3 : 1.0)
                    }
                    .disabled(currentPage == 0)
                    
                    Spacer()
                    
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        hasSeenOnboarding = true
                    }) {
                        Text("Skip")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.35, green: 0.60, blue: 0.95))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                // Header with glassmorphic icon
                VStack(spacing: 12) {
                    // Glassmorphic bubble for logo
                    ZStack {
                        // Real glassmorphism effect
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.25),
                                        Color.white.opacity(0.10)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Glassmorphic border
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.60),
                                        Color.white.opacity(0.15)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                        
                        // Inner shadow effect
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Logo icon - using book symbol
                        Image(systemName: "book.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(Color(red: 0.30, green: 0.60, blue: 0.95))
                    }
                    .frame(width: 110, height: 110)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.white.opacity(0.05))
                            .blur(radius: 20)
                    )
                    
                    Text("Smart Study Companion")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(red: 0.20, green: 0.35, blue: 0.65))
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // TabView with pages
                TabView(selection: $currentPage) {
                    OnboardingPage1(hoveredCard: $hoveredCard, pageIndex: 0)
                        .tag(0)
                    
                    OnboardingPage2(hoveredCard: $hoveredCard, pageIndex: 1)
                        .tag(1)
                    
                    OnboardingPage3(hoveredCard: $hoveredCard, pageIndex: 2)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(maxHeight: .infinity)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        } else {
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                            hasSeenOnboarding = true
                        }
                    }) {
                        Text(currentPage < 2 ? "Next" : "Get Started")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.40, green: 0.70, blue: 0.99),
                                        Color(red: 0.30, green: 0.60, blue: 0.95)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0.30, green: 0.60, blue: 0.95).opacity(0.4), radius: 16, x: 0, y: 10)
                    }
                    
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        hasSeenOnboarding = true
                    }) {
                        Text(currentPage < 2 ? "Skip Tutorial" : "I have an account")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.35, green: 0.60, blue: 0.95))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.3))
                                    .backdrop()
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
}

/// Page 1 - Create & Organize Notes
struct OnboardingPage1: View {
    @Binding var hoveredCard: Int?
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Glassmorphic card with illustration
            ZStack {
                GlassmorphicCard(isHovered: hoveredCard == pageIndex)
                
                VStack(spacing: 20) {
                    // Illustration placeholder - book/notes
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.95, green: 0.75, blue: 0.85).opacity(0.6),
                                        Color(red: 0.90, green: 0.70, blue: 0.80).opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(Color(red: 0.85, green: 0.50, blue: 0.70))
                            
                            Text("Notes")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.70, green: 0.35, blue: 0.55))
                        }
                    }
                    .frame(height: 120)
                    
                    // Text content
                    VStack(spacing: 8) {
                        Text("Create & Organize Your Notes")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.15, green: 0.30, blue: 0.60))
                        
                        Text("Write and organize your study materials. Attach PDFs, images, and information. Everything syncs seamlessly in one place.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.40, green: 0.50, blue: 0.70))
                            .lineSpacing(2)
                    }
                }
                .padding(.vertical, 28)
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, 20)
            .frame(height: 380)
            .scaleEffect(hoveredCard == pageIndex ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: hoveredCard)
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

/// Page 2 - Chat with AI Assistant
struct OnboardingPage2: View {
    @Binding var hoveredCard: Int?
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                GlassmorphicCard(isHovered: hoveredCard == pageIndex)
                
                VStack(spacing: 20) {
                    // Chat illustration
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.85, green: 0.95, blue: 0.90).opacity(0.6),
                                        Color(red: 0.80, green: 0.92, blue: 0.85).opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(Color(red: 0.30, green: 0.75, blue: 0.60))
                            
                            Text("AI Chat")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.20, green: 0.65, blue: 0.50))
                        }
                    }
                    .frame(height: 120)
                    
                    VStack(spacing: 8) {
                        Text("Chat with Your AI Assistant")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.15, green: 0.30, blue: 0.60))
                        
                        Text("Ask questions, get summaries, create study plans, generate quizzes, and flashcards. Your AI assistant learns your study style and adapts.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.40, green: 0.50, blue: 0.70))
                            .lineSpacing(2)
                    }
                }
                .padding(.vertical, 28)
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, 20)
            .frame(height: 380)
            .scaleEffect(hoveredCard == pageIndex ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: hoveredCard)
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

/// Page 3 - Achieve Study Goals
struct OnboardingPage3: View {
    @Binding var hoveredCard: Int?
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                GlassmorphicCard(isHovered: hoveredCard == pageIndex)
                
                VStack(spacing: 20) {
                    // Achievement illustration
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.99, green: 0.90, blue: 0.75).opacity(0.6),
                                        Color(red: 0.96, green: 0.85, blue: 0.70).opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.20))
                            
                            Text("Goals")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.85, green: 0.60, blue: 0.10))
                        }
                    }
                    .frame(height: 120)
                    
                    VStack(spacing: 8) {
                        Text("Achieve Your Study Goals")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.15, green: 0.30, blue: 0.60))
                        
                        Text("Generate personalized action plans, create flashcards, take adaptive quizzes, and track your progress. Achieve more in less time.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.40, green: 0.50, blue: 0.70))
                            .lineSpacing(2)
                    }
                }
                .padding(.vertical, 28)
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, 20)
            .frame(height: 380)
            .scaleEffect(hoveredCard == pageIndex ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: hoveredCard)
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

/// Glassmorphic card component
struct GlassmorphicCard: View {
    let isHovered: Bool
    
    var body: some View {
        ZStack {
            // Back blur layer
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white.opacity(isHovered ? 0.35 : 0.25))
                .backdrop()
            
            // Top glossy shine
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(isHovered ? 0.45 : 0.35),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 100)
                .blur(radius: 2)
            
            // Border
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(isHovered ? 0.70 : 0.50),
                            Color.white.opacity(0.20)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
            
            // Shadow effect
            if isHovered {
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.35, green: 0.65, blue: 0.98).opacity(0.15),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .blur(radius: 8)
            }
        }
    }
}

/// Custom backdrop blur extension
extension View {
    func backdrop() -> some View {
        self.background(.ultraThinMaterial)
    }
}

#Preview {
    @Previewable @State var hasSeenOnboarding = false
    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
}
