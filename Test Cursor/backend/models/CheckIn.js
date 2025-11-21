const mongoose = require('mongoose');

const CheckInSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    date: {
      type: Date,
      required: true,
      default: Date.now,
    },
    status: {
      type: String,
      enum: ['clean', 'relapse', 'skipped'],
      default: 'clean',
    },
    checkInTime: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

CheckInSchema.index({ userId: 1, date: -1 });

module.exports = mongoose.model('CheckIn', CheckInSchema);


