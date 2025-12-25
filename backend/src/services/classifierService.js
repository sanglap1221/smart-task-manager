const classifyTask = (title, description) => {
  const content = `${title} ${description}`.toLowerCase();

  // pririty
  let category = 'general';

  if (/safety|hazard|inspection|compliance|ppe/.test(content)) {
    category = 'safety';
  } else if (/meeting|schedule|call|appointment|deadline/.test(content)) {
    category = 'scheduling';
  } else if (/payment|invoice|bill|budget|cost|expense/.test(content)) {
    category = 'finance';
  } else if (/bug|fix|error|install|repair|maintain/.test(content)) {
    category = 'technical';
  }

  let priority = 'low';

  if (/urgent|asap|immediately|today|critical|emergency/.test(content)) {
    priority = 'high';
  } else if (/soon|this week|important/.test(content)) {
    priority = 'medium';
  }

  const entities = {
    people: [],
    locations: [],
    dates: []
  };

  // person name after "with", "assign to", or "by"
  const personMatch = content.match(/(?:with|assign to|by)\s+([a-z]+)/i);
  if (personMatch) {
    entities.people.push(personMatch[1]);
  }

  // Actions
  const actionMap = {
    scheduling: ["Block calendar", "Send invite", "Prepare agenda", "Set reminder"],
    finance: ["Check budget", "Get approval", "Generate invoice", "Update records"],
    technical: ["Diagnose issue", "Check resources", "Assign technician", "Document fix"],
    safety: ["Conduct inspection", "File report", "Notify supervisor", "Update checklist"],
    general: ["Review task", "Set deadline"]
  };

  return {
    category,
    priority,
    extracted_entities: entities,
    suggested_actions: actionMap[category]
  };
};

module.exports = { classifyTask };
