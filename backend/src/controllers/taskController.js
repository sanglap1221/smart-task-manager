const supabase = require('../utils/supabaseClient');
const { classifyTask } = require('../services/classifierService');
const { z } = require('zod');

// Validation schemas
const taskSchema = z.object({
    title: z.string().min(1, 'Title is required'),
    description: z.string().min(1, 'Description is required'),
    assigned_to: z.string().optional().nullable(),
    due_date: z.string().optional().nullable(),
    category: z.string().optional(),
    priority: z.string().optional(),
    status: z.enum(['pending', 'in_progress', 'completed']).optional(),
});

const classifySchema = z.object({
    title: z.string().min(1, 'Title is required'),
    description: z.string().min(1, 'Description is required'),
});

// POST /api/tasks/classify - Preview classification without saving
exports.classifyTaskPreview = async (req, res) => {
    try {
        const { title, description } = classifySchema.parse(req.body);
        const classification = classifyTask(title, description);
        res.status(200).json(classification);
    } catch (err) {
        if (err instanceof z.ZodError) {
            return res.status(400).json({ error: err.errors[0].message });
        }
        res.status(400).json({ error: err.message });
    }
};

// POST /api/tasks
exports.createTask = async (req, res) => {
    try {
        const { title, description, assigned_to, due_date, category, priority } = taskSchema.parse(req.body);
        const analysis = classifyTask(title, description);
        const finalCategory = category ?? analysis.category;
        const finalPriority = priority ?? analysis.priority;

        const { data, error } = await supabase
            .from('tasks')
            .insert([
                {
                    title,
                    description,
                    assigned_to,
                    due_date,
                    category: finalCategory,
                    priority: finalPriority,
                    extracted_entities: analysis.extracted_entities,
                    suggested_actions: analysis.suggested_actions,
                    status: 'pending',
                },
            ])
            .select();

        if (error) throw error;
        res.status(201).json({ data: data[0] });
    } catch (err) {
        if (err instanceof z.ZodError) {
            return res.status(400).json({ error: err.errors[0].message });
        }
        res.status(400).json({ error: err.message });
    }
};

// GET /api/tasks 
exports.getAllTasks = async (req, res) => {
    try {
        const { status, category, priority, limit = 10, offset = 0 } = req.query;
        let query = supabase.from('tasks').select('*', { count: 'exact' });

        if (status) query = query.eq('status', status);
        if (category) query = query.eq('category', category);
        if (priority) query = query.eq('priority', priority);

        const { data, error, count } = await query
            .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

        if (error) throw error;
        res.status(200).json({ data, count });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// GET /api/tasks/:id
exports.getTaskById = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('tasks')
            .select('*')
            .eq('id', id)
            .single();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Task not found' });
        
        res.status(200).json({ data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /api/tasks/:id
exports.updateTask = async (req, res) => {
    try {
        const { id } = req.params;
        const updateData = taskSchema.partial().parse(req.body);

        // Get current task to track status change
        const { data: currentTask, error: fetchError } = await supabase
            .from('tasks')
            .select('*')
            .eq('id', id)
            .single();

        if (fetchError) throw fetchError;
        if (!currentTask) return res.status(404).json({ error: 'Task not found' });

        // Update task
        const { data, error } = await supabase
            .from('tasks')
            .update(updateData)
            .eq('id', id)
            .select();

        if (error) throw error;
        if (data.length === 0) return res.status(404).json({ error: 'Task not found' });

        // Track status change in task_history if status was updated
        if (updateData.status && updateData.status !== currentTask.status) {
            await supabase.from('task_history').insert([
                {
                    task_id: id,
                    action: 'status_changed',
                    old_value: currentTask.status,
                    new_value: updateData.status,
                    changed_at: new Date().toISOString(),
                },
            ]);
        }
        
        res.status(200).json({ data: data[0] });
    } catch (err) {
        if (err instanceof z.ZodError) {
            return res.status(400).json({ error: err.errors[0].message });
        }
        res.status(500).json({ error: err.message });
    }
};

// DELETE /api/tasks/:id
exports.deleteTask = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await supabase
            .from('tasks')
            .delete()
            .eq('id', id);

        if (error) throw error;
        res.status(200).json({ message: 'Task deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};  