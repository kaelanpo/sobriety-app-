const DAY_IN_MS = 24 * 60 * 60 * 1000;

const MILESTONES = [
  { id: 1, name: 'First Day', days: 1 },
  { id: 2, name: 'One Week', days: 7 },
  { id: 3, name: 'Two Weeks', days: 14 },
  { id: 4, name: 'One Month', days: 30 },
  { id: 5, name: 'Three Months', days: 90 },
  { id: 6, name: 'Six Months', days: 180 },
  { id: 7, name: 'One Year', days: 365 },
];

const STATUS_PRIORITY = {
  relapse: 3,
  skipped: 2,
  clean: 1,
};

const formatDateKey = (date) => {
  const d = new Date(date);
  const year = d.getUTCFullYear();
  const month = `${d.getUTCMonth() + 1}`.padStart(2, '0');
  const day = `${d.getUTCDate()}`.padStart(2, '0');
  return `${year}-${month}-${day}`;
};

const stripTime = (date) => new Date(formatDateKey(date));

const sortByDateAsc = (a, b) => new Date(a.date) - new Date(b.date);
const sortByDateDesc = (a, b) => new Date(b.date) - new Date(a.date);

const normalizeDailyStatuses = (checkIns) => {
  const sorted = [...checkIns].sort(sortByDateDesc);
  const byDate = new Map();

  for (const entry of sorted) {
    const key = formatDateKey(entry.date);
    const priority = STATUS_PRIORITY[entry.status] ?? 0;
    const existing = byDate.get(key);
    if (!existing || priority > existing.priority) {
      byDate.set(key, { status: entry.status, priority });
    }
  }

  return Array.from(byDate.entries())
    .map(([date, value]) => ({ date, status: value.status }))
    .sort(sortByDateAsc);
};

const calculateStreaks = (checkIns) => {
  if (!checkIns?.length) {
    return { currentStreak: 0, longestStreak: 0 };
  }

  const dailyStatuses = normalizeDailyStatuses(checkIns);

  let longestStreak = 0;
  let rollingStreak = 0;
  let previousDate = null;

  for (const entry of dailyStatuses) {
    if (entry.status !== 'clean') {
      rollingStreak = 0;
      previousDate = new Date(entry.date);
      longestStreak = Math.max(longestStreak, rollingStreak);
      continue;
    }

    const currentDate = new Date(entry.date);
    if (
      previousDate &&
      Math.round((currentDate - previousDate) / DAY_IN_MS) === 1
    ) {
      rollingStreak += 1;
    } else {
      rollingStreak = 1;
    }
    previousDate = currentDate;
    longestStreak = Math.max(longestStreak, rollingStreak);
  }

  const today = new Date();
  let currentStreak = 0;
  let lastDate = null;

  for (let i = dailyStatuses.length - 1; i >= 0; i -= 1) {
    const entry = dailyStatuses[i];
    if (entry.status !== 'clean') {
      break;
    }

    const entryDate = new Date(entry.date);
    if (!lastDate) {
      const diffFromToday = Math.round(
        (stripTime(today) - stripTime(entryDate)) / DAY_IN_MS
      );
      if (diffFromToday > 1) {
        break;
      }
      currentStreak = 1;
      lastDate = entryDate;
      continue;
    }

    const diff = Math.round((lastDate - entryDate) / DAY_IN_MS);
    if (diff === 1) {
      currentStreak += 1;
      lastDate = entryDate;
    } else {
      break;
    }
  }

  return { currentStreak, longestStreak };
};

const calculateTrendData = (checkIns, days = 90) => {
  const today = stripTime(new Date());
  const startDate = new Date(today - (days - 1) * DAY_IN_MS);
  const buckets = Math.ceil(days / 7);

  const dailyStatuses = normalizeDailyStatuses(checkIns);
  const statusMap = new Map(
    dailyStatuses.map((entry) => [entry.date, entry.status])
  );

  const data = [];
  for (let bucketIndex = 0; bucketIndex < buckets; bucketIndex += 1) {
    const bucketStart = new Date(startDate.getTime() + bucketIndex * 7 * DAY_IN_MS);
    const bucketEnd = new Date(
      Math.min(today.getTime(), bucketStart.getTime() + 6 * DAY_IN_MS)
    );

    let cleanCount = 0;
    for (
      let day = stripTime(bucketStart);
      day <= bucketEnd;
      day = new Date(day.getTime() + DAY_IN_MS)
    ) {
      const key = formatDateKey(day);
      if (statusMap.get(key) === 'clean') {
        cleanCount += 1;
      }
    }

    data.push({
      date: formatDateKey(bucketEnd),
      cleanDays: cleanCount,
    });
  }

  return data;
};

const generateInsights = (checkIns) => {
  const buckets = {
    morning: { label: 'Morning (5am - 12pm)', count: 0 },
    afternoon: { label: 'Afternoon (12pm - 5pm)', count: 0 },
    evening: { label: 'Evening (5pm - 9pm)', count: 0 },
    night: { label: 'Night (9pm - 5am)', count: 0 },
  };

  const relapseDays = new Map();

  checkIns.forEach((entry) => {
    const date = new Date(entry.date);
    const hour = entry.checkInTime ? new Date(entry.checkInTime).getHours() : date.getHours();

    if (entry.status === 'clean') {
      let bucketKey = 'morning';
      if (hour >= 12 && hour < 17) bucketKey = 'afternoon';
      else if (hour >= 17 && hour < 21) bucketKey = 'evening';
      else if (hour >= 21 || hour < 5) bucketKey = 'night';
      buckets[bucketKey].count += 1;
    }

    if (entry.status === 'relapse') {
      const day = date.toLocaleDateString('en-US', { weekday: 'long' });
      relapseDays.set(day, (relapseDays.get(day) ?? 0) + 1);
    }
  });

  const strongestTime =
    Object.values(buckets).reduce((prev, curr) =>
      curr.count > prev.count ? curr : prev
    ).count > 0
      ? Object.values(buckets).reduce((prev, curr) =>
          curr.count > prev.count ? curr : prev
        ).label
      : 'Not enough data yet';

  let triggerDay = 'No pattern yet';
  let maxRelapseCount = 0;
  relapseDays.forEach((count, day) => {
    if (count > maxRelapseCount) {
      triggerDay = day;
      maxRelapseCount = count;
    }
  });

  return {
    strongestTime,
    triggerDay,
  };
};

const getMilestones = (longestStreak) =>
  MILESTONES.map((milestone) => ({
    ...milestone,
    unlocked: longestStreak >= milestone.days,
  }));

const shapeAnalysisPayload = ({
  streaks,
  trendData,
  insights,
  milestones,
}) => {
  const nextMilestone = milestones.find((milestone) => !milestone.unlocked);
  const nextMilestoneDays = nextMilestone ? nextMilestone.days : streaks.longestStreak;
  const daysToGo = Math.max(nextMilestoneDays - streaks.currentStreak, 0);

  return {
    currentStreak: streaks.currentStreak,
    longestStreak: streaks.longestStreak,
    nextMilestoneDays,
    daysToGo,
    trendData,
    insights,
    milestones,
  };
};

const buildAnalysis = (checkIns) => {
  const streaks = calculateStreaks(checkIns);
  const trendData = calculateTrendData(checkIns);
  const insights = generateInsights(checkIns);
  const milestones = getMilestones(streaks.longestStreak);

  return shapeAnalysisPayload({ streaks, trendData, insights, milestones });
};

module.exports = {
  calculateStreaks,
  calculateTrendData,
  generateInsights,
  getMilestones,
  buildAnalysis,
};


