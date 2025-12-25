const { classifyTask } = require('../src/services/classifierService');

describe('Auto-Classification Logic Tests', () => {
  
  // Category Detection (Safety)
  test('Should classify as "safety" when hazard keywords are present', () => {
    const result = classifyTask("Fix pipe", "There is a safety hazard in Zone A");
    expect(result.category).toBe('safety');
    expect(result.suggested_actions).toContain('Conduct inspection');
  });

  // Priority Detection (High)
  test('Should assign "high" priority for urgent keywords', () => {
    const result = classifyTask("Budget report", "This is urgent and must be done today");
    expect(result.priority).toBe('high');
  });

  // Default Behavior
  test('Should fallback to "general" category and "low" priority for unknown text', () => {
    const result = classifyTask("Check something", "Just a regular task with no special keywords");
    expect(result.category).toBe('general');
    expect(result.priority).toBe('low');
  });

});