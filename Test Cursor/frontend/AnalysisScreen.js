import React from 'react';
import { ScrollView, View, Text, StyleSheet, Dimensions } from 'react-native';
import { VictoryArea, VictoryAxis, VictoryChart, VictoryTheme } from 'victory-native';

const mockAnalysisData = {
  currentStreak: 7,
  longestStreak: 32,
  nextMilestoneDays: 30,
  daysToGo: 23,
  trendData: Array.from({ length: 12 }).map((_, index) => ({
    date: `2025-0${Math.floor(index / 4) + 1}-0${(index % 4) * 7 + 1}`,
    cleanDays: Math.max(0, 5 + (index % 4) - Math.floor(index / 6)),
  })),
  insights: {
    strongestTime: 'Morning (7am - 10am)',
    triggerDay: 'Fridays',
  },
  milestones: [
    { id: 1, name: 'First Day', days: 1, unlocked: true },
    { id: 2, name: 'One Week', days: 7, unlocked: true },
    { id: 3, name: 'Two Weeks', days: 14, unlocked: false },
    { id: 4, name: 'One Month', days: 30, unlocked: false },
  ],
};

const { width } = Dimensions.get('window');

const AnalysisScreen = () => {
  const progressPercentage = Math.min(
    (mockAnalysisData.currentStreak / mockAnalysisData.nextMilestoneDays) * 100,
    100
  );

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <View style={styles.headerSection}>
        <Text style={styles.title}>Analysis</Text>
        <Text style={styles.subtitle}>Your progress and trends over time.</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.cardLabel}>Current Progress</Text>
        <View style={styles.streakRow}>
          <View>
            <Text style={styles.streakValue}>{mockAnalysisData.currentStreak} days</Text>
            <Text style={styles.streakDescription}>Current Streak</Text>
          </View>
          <View>
            <Text style={styles.streakValue}>{mockAnalysisData.longestStreak} days</Text>
            <Text style={styles.streakDescription}>Longest Streak</Text>
          </View>
        </View>
        <View style={styles.progressWrapper}>
          <Text style={styles.progressLabel}>
            Next Milestone: {mockAnalysisData.nextMilestoneDays} days clean
          </Text>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${progressPercentage}%` }]} />
          </View>
          <Text style={styles.progressSubLabel}>
            {mockAnalysisData.daysToGo} days to go
          </Text>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Consistency Trend</Text>
        <View style={styles.chartCard}>
          <VictoryChart
            width={width - 48}
            height={220}
            padding={{ top: 32, bottom: 48, left: 52, right: 24 }}
            theme={VictoryTheme.material}
          >
            <VictoryAxis
              tickFormat={(t) => t.slice(5)}
              style={{
                axis: { stroke: '#d9dce3' },
                ticks: { size: 0 },
                tickLabels: { fill: '#6f7384', fontSize: 10, padding: 12 },
              }}
            />
            <VictoryAxis
              dependentAxis
              tickFormat={(t) => `${t}`}
              style={{
                axis: { stroke: '#d9dce3' },
                ticks: { size: 0 },
                tickLabels: { fill: '#6f7384', fontSize: 10, padding: 8 },
                grid: { stroke: '#eef0f5' },
              }}
            />
            <VictoryArea
              interpolation="monotoneX"
              data={mockAnalysisData.trendData}
              x="date"
              y="cleanDays"
              style={{
                data: { fill: 'rgba(112, 82, 255, 0.2)', stroke: '#7052ff', strokeWidth: 3 },
              }}
            />
          </VictoryChart>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Personalized Insights</Text>
        <View style={styles.insightsContainer}>
          <InsightCard
            title="Strength Spot"
            description={`Your strongest time for checking in is ${mockAnalysisData.insights.strongestTime}.`}
          />
          <InsightCard
            title="Relapse Trigger Insight"
            description={`You tend to feel the urge to break your streak most often on ${mockAnalysisData.insights.triggerDay}.`}
          />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Milestones</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {mockAnalysisData.milestones.map((milestone) => (
            <MilestoneCard key={milestone.id} milestone={milestone} />
          ))}
        </ScrollView>
      </View>

      <View style={styles.quoteCard}>
        <Text style={styles.quote}>
          You are worthy of a healthy, fulfilling life.
        </Text>
      </View>
    </ScrollView>
  );
};

const InsightCard = ({ title, description }) => (
  <View style={styles.insightCard}>
    <Text style={styles.insightTitle}>{title}</Text>
    <Text style={styles.insightDescription}>{description}</Text>
  </View>
);

const MilestoneCard = ({ milestone }) => {
  const unlockedStyles = milestone.unlocked
    ? [styles.milestoneCard, styles.milestoneUnlocked]
    : [styles.milestoneCard, styles.milestoneLocked];
  const textColor = milestone.unlocked ? '#ffffff' : '#1b1e36';
  const subTextColor = milestone.unlocked ? '#d8d9f7' : '#6f7384';

  return (
    <View style={unlockedStyles}>
      <Text style={[styles.milestoneName, { color: textColor }]}>{milestone.name}</Text>
      <Text style={[styles.milestoneDays, { color: textColor }]}>
        {milestone.days} days
      </Text>
      <Text style={[styles.milestoneStatus, { color: subTextColor }]}>
        {milestone.unlocked ? 'Unlocked' : 'Next Goal'}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f6fa',
  },
  contentContainer: {
    padding: 24,
    paddingBottom: 48,
  },
  headerSection: {
    marginBottom: 24,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    color: '#1b1e36',
  },
  subtitle: {
    marginTop: 8,
    fontSize: 16,
    color: '#6f7384',
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 20,
    padding: 24,
    marginBottom: 24,
    shadowColor: '#2d2d2d',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  cardLabel: {
    color: '#6f7384',
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 16,
  },
  streakRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  streakValue: {
    fontSize: 28,
    fontWeight: '700',
    color: '#1b1e36',
  },
  streakDescription: {
    fontSize: 14,
    color: '#8a8fa4',
    marginTop: 4,
  },
  progressWrapper: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#eceef5',
    paddingTop: 20,
  },
  progressLabel: {
    fontSize: 14,
    color: '#6f7384',
    marginBottom: 12,
  },
  progressBar: {
    height: 12,
    borderRadius: 12,
    backgroundColor: '#eceef5',
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#7052ff',
    borderRadius: 12,
  },
  progressSubLabel: {
    fontSize: 12,
    color: '#8a8fa4',
    marginTop: 8,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: '600',
    color: '#1b1e36',
    marginBottom: 16,
  },
  chartCard: {
    backgroundColor: '#ffffff',
    borderRadius: 20,
    paddingVertical: 24,
    alignItems: 'center',
    shadowColor: '#2d2d2d',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  insightsContainer: {
    gap: 16,
  },
  insightCard: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 20,
    shadowColor: '#2d2d2d',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.05,
    shadowRadius: 8,
    elevation: 1,
  },
  insightTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1b1e36',
    marginBottom: 8,
  },
  insightDescription: {
    fontSize: 14,
    color: '#6f7384',
    lineHeight: 20,
  },
  milestoneCard: {
    width: 160,
    padding: 20,
    borderRadius: 18,
    marginRight: 16,
    borderWidth: 1,
    borderColor: 'transparent',
  },
  milestoneUnlocked: {
    backgroundColor: '#7052ff',
    borderColor: '#7052ff',
  },
  milestoneLocked: {
    backgroundColor: '#ffffff',
    borderColor: '#d9dce3',
  },
  milestoneName: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 12,
  },
  milestoneDays: {
    fontSize: 18,
    fontWeight: '700',
  },
  milestoneStatus: {
    marginTop: 12,
    fontSize: 14,
  },
  quoteCard: {
    backgroundColor: '#ffffff',
    borderRadius: 20,
    padding: 24,
    shadowColor: '#2d2d2d',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.04,
    shadowRadius: 10,
    elevation: 2,
  },
  quote: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1b1e36',
    lineHeight: 26,
    textAlign: 'center',
  },
});

export default AnalysisScreen;


