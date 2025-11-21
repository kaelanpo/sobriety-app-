const express = require('express');

const router = express.Router();

const CheckIn = require('../models/CheckIn');
const { buildAnalysis } = require('../services/AnalysisService');

router.get('/:userId', async (req, res, next) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required.' });
    }

    const checkIns = await CheckIn.find({ userId }).lean().exec();
    const analysis = buildAnalysis(checkIns);

    return res.json(analysis);
  } catch (error) {
    return next(error);
  }
});

module.exports = router;


