//
//  OnboardingFlowUITests.swift
//  reflectUITests
//
//  Created by Austin English on 1/13/26.
//

import XCTest

/// UI Tests for the onboarding flow
/// Tests the complete user journey through onboarding screens
final class OnboardingFlowUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-onboarding"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Complete Flow Tests
    
    func testCompleteOnboardingFlow() throws {
        // Welcome Screen
        XCTAssertTrue(app.staticTexts["Welcome to Reflect"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Social media where you're the only follower"].exists)
        
        // Check feature highlights
        XCTAssertTrue(app.staticTexts["Familiar & Beautiful"].exists)
        XCTAssertTrue(app.staticTexts["Track Your Well-Being"].exists)
        XCTAssertTrue(app.staticTexts["Relive Your Moments"].exists)
        XCTAssertTrue(app.staticTexts["Understand Yourself"].exists)
        XCTAssertTrue(app.staticTexts["Share When Ready"].exists)
        
        // Tap Get Started
        app.buttons["Get Started"].tap()
        
        // Privacy Screen
        XCTAssertTrue(app.staticTexts["100% Private, 0% Social"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.staticTexts["No Social Pressure"].exists)
        XCTAssertTrue(app.staticTexts["No Data Collection"].exists)
        
        // Continue to Sign Up
        app.buttons["Continue"].tap()
        
        // Sign Up Screen
        XCTAssertTrue(app.staticTexts["Create Your Account"].waitForExistence(timeout: 1))
        
        // Enter name
        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText("John Doe")
        
        // Optionally enter email
        let emailField = app.textFields["your@email.com"]
        emailField.tap()
        emailField.typeText("john@example.com")
        
        // Continue to Persona Setup
        app.buttons["Continue"].tap()
        
        // Persona Setup Screen
        XCTAssertTrue(app.staticTexts["Create Your First Persona"].waitForExistence(timeout: 1))
        
        // Change persona name if desired
        let personaNameField = app.textFields["Personal"]
        if personaNameField.exists {
            personaNameField.tap()
            personaNameField.clearText()
            personaNameField.typeText("My Life")
        }
        
        // Select a color
        // Note: Color buttons might need accessibility identifiers
        // For now, just complete with default
        
        // Complete onboarding
        app.buttons["Complete Setup"].tap()
        
        // Should transition to main app
        // Verify onboarding is no longer shown
        XCTAssertFalse(app.staticTexts["Welcome to Reflect"].waitForExistence(timeout: 2))
    }
    
    func testNavigationBackAndForth() throws {
        // Start at Welcome
        XCTAssertTrue(app.staticTexts["Welcome to Reflect"].waitForExistence(timeout: 2))
        
        // Go forward to Privacy
        app.buttons["Get Started"].tap()
        XCTAssertTrue(app.staticTexts["100% Private, 0% Social"].waitForExistence(timeout: 1))
        
        // Go back to Welcome
        app.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Welcome to Reflect"].exists)
        
        // Go forward again
        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.staticTexts["Create Your Account"].waitForExistence(timeout: 1))
        
        // Go back to Privacy
        app.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["100% Private, 0% Social"].exists)
    }
    
    func testSignUpValidation() throws {
        // Navigate to Sign Up
        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()
        
        XCTAssertTrue(app.staticTexts["Create Your Account"].waitForExistence(timeout: 1))
        
        // Try to continue without name (button should be disabled)
        let continueButton = app.buttons["Continue"]
        XCTAssertFalse(continueButton.isEnabled)
        
        // Enter name (too short)
        let nameField = app.textFields["Your name"]
        nameField.tap()
        nameField.typeText("J")
        
        // Try to continue (should show error or still be disabled)
        if continueButton.isEnabled {
            continueButton.tap()
            // Check for error message
            XCTAssertTrue(app.staticTexts["Name must be at least 2 characters"].waitForExistence(timeout: 1))
        }
        
        // Fix the name
        nameField.tap()
        nameField.clearText()
        nameField.typeText("John Doe")
        
        // Now continue button should work
        continueButton.tap()
        XCTAssertTrue(app.staticTexts["Create Your First Persona"].waitForExistence(timeout: 1))
    }
    
    func testEmailValidation() throws {
        // Navigate to Sign Up
        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()
        
        // Enter valid name
        let nameField = app.textFields["Your name"]
        nameField.tap()
        nameField.typeText("John Doe")
        
        // Enter invalid email
        let emailField = app.textFields["your@email.com"]
        emailField.tap()
        emailField.typeText("notanemail")
        
        // Try to continue
        app.buttons["Continue"].tap()
        
        // Should show error
        XCTAssertTrue(app.staticTexts["Please enter a valid email address"].waitForExistence(timeout: 1))
        
        // Fix email
        emailField.tap()
        emailField.clearText()
        emailField.typeText("john@example.com")
        
        // Should be able to continue now
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.staticTexts["Create Your First Persona"].waitForExistence(timeout: 1))
    }
    
    func testPersonaColorSelection() throws {
        // Complete flow to persona setup
        navigateToPersonaSetup()
        
        XCTAssertTrue(app.staticTexts["Create Your First Persona"].waitForExistence(timeout: 1))
        
        // Test that color picker exists
        XCTAssertTrue(app.staticTexts["Color"].exists)
        
        // Verify info text
        XCTAssertTrue(app.staticTexts["You can create more personas later"].exists)
    }
    
    func testSkipOptionalFields() throws {
        // Navigate through without entering optional email
        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()
        
        // Only enter name (skip email)
        let nameField = app.textFields["Your name"]
        nameField.tap()
        nameField.typeText("John Doe")
        
        app.buttons["Continue"].tap()
        
        // Should work fine - email is optional
        XCTAssertTrue(app.staticTexts["Create Your First Persona"].waitForExistence(timeout: 1))
        
        // Use default persona name and color
        app.buttons["Complete Setup"].tap()
        
        // Should complete successfully
        XCTAssertFalse(app.staticTexts["Welcome to Reflect"].waitForExistence(timeout: 2))
    }
    
    // MARK: - Helper Methods
    
    private func navigateToPersonaSetup() {
        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()
        
        let nameField = app.textFields["Your name"]
        nameField.tap()
        nameField.typeText("Test User")
        
        app.buttons["Continue"].tap()
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    /// Clears text from a text field
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        // Tap to focus
        self.tap()
        
        // Select all
        self.press(forDuration: 1.0)
        
        // Delete
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
