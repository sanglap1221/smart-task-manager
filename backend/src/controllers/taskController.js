const supabase = require('../utils/supabaseClient');
const { classifyTask } = require('../services/classifierService');

// POST /api/tasks
exports.createTask = async (req, res) => {
    try {
        const { title, description, assigned_to, due_date } = req.body;
        const analysis = classifyTask(title, description);

        const { data, error } = await supabase
            .from('tasks')
            .insert([{ 
                title, 
                description, 
                assigned_to, 
                due_date,
                ...analysis,
                status: 'pending' 
            }])
            .select();

        if (error) throw error;
        res.status(201).json(data[0]);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};

// GET api tasks 
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

// Define placeholders
exports.getTaskById = async (req, res) => res.json({ message: "Not implemented yet" });
exports.updateTask = async (req, res) => res.json({ message: "Not implemented yet" });
exports.deleteTask = async (req, res) => res.json({ message: "Not implemented yet" });  