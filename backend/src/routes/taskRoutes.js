const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');

router.post('/tasks/classify', taskController.classifyTaskPreview);  // Preview classification
router.post('/tasks', taskController.createTask);                   // Create task
router.get('/tasks', taskController.getAllTasks);                   // Get all tasks
router.get('/tasks/:id', taskController.getTaskById);               // Get single task
router.patch('/tasks/:id', taskController.updateTask);              // Update task
router.delete('/tasks/:id', taskController.deleteTask);             // Delete task

module.exports = router;